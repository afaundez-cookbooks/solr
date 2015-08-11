action :setup do
  home_path = @new_resource.home
  source_url = source_url_for_version @new_resource.version
  source_path = ::File.join(home_path, ::File.basename(source_url, '.tgz'))

  unless exists?(source_path)
    directory home_path

    tar_extract source_url do
      target_dir home_path
      creates source_path
    end
  end

  data_path = ::File.join(@new_resource.data_dir, ::File.basename(source_url, '.tgz'), @new_resource.name)
  directory data_path do
    recursive  true
  end

  if @new_resource.multicore
    execute "cp -R #{::File.join(source_path, 'example', 'multicore', '*')} #{data_path}"
    template_conf_path = ::File.join(data_path, 'template', 'conf')
    directory template_conf_path do
      recursive true
    end
    core_template_cookbook = @new_resource.core_template_cookbook
    unless core_template_cookbook.nil?
      cookbook_file ::File.join(template_conf_path, 'solrconfig.xml') do
        cookbook core_template_cookbook
        source 'solrconfig.xml'
      end
      cookbook_file ::File.join(template_conf_path, 'schema.xml') do
        cookbook core_template_cookbook
        source 'schema.xml'
      end
      solr_xml_path = ::File.join(data_path, 'solr.xml')
      cookbook_file solr_xml_path do
        cookbook core_template_cookbook
        source 'solr.xml'
        persistent = '<solr persistent="true">'
        not_if "grep '#{persistent}' #{solr_xml_path}"
      end
    end
  else
    execute "cp -R #{::File.join(source_path, 'example', 'solr', '*')} #{data_path}"
  end

  # jetty_conf = "-Djetty.port=#{@new_resource.start_port} -Djetty.home=#{data_path}"
  jetty_conf = "-Djetty.port=#{@new_resource.start_port}"
  stop_key = @new_resource.stop_key
  stop_conf = "-DSTOP.PORT=#{@new_resource.stop_port} -DSTOP.KEY=#{stop_key}"
  # data_conf = @new_resource.data_dir.nil? ? nil : "-Dsolr.data.dir=#{::File.join(@new_resource.data_dir, @new_resource.stop_key)}"
  # multicore_conf = @new_resource.multicore ? "-Dsolr.solr.home=#{source_path}/example/multicore" : "-Dsolr.solr.home=#{source_path}/example/solr"
  home_conf =  "-Dsolr.solr.home=#{data_path}"
  # newrelic_conf = nil
  # unless @new_resource.newrelic_jar_url.nil?
  #   newrelic_jar_url = @new_resource.newrelic_jar_url
  #   remote_file ::File.join(source_path, 'example', 'newrelic.jar') do
  #     source newrelic_jar_url
  #     action :create_if_missing
  #   end
  #   newrelic_template_cookbook = @new_resource.newrelic_template_cookbook
  #   template ::File.join(source_path, 'example', 'newrelic.yml') do
  #     source 'newrelic.yml.erb'
  #     cookbook newrelic_template_cookbook
  #     variables :app_name => stop_key
  #   end
  #   newrelic_conf = "-javaagent:#{::File.join(source_path, 'example', 'newrelic.jar')}"
  # end
  jar_conf = "-jar #{::File.join(source_path, 'example', 'start.jar')}"
  java_command = 'java'
  command =  [java_command, stop_conf, home_conf, jetty_conf, jar_conf].compact.join(' ')

  log command

  # include_recipe 'monit'
  #
  # template "#{source_path}/example/wrapper.sh" do
  #   source 'wrapper.sh.erb'
  #   mode 0755
  #   cookbook 'solr'
  #   variables :command => command, :pidfilename => stop_key, :cwd => ::File.join(source_path, 'example')
  # end
  #
  # monitrc stop_key do
  #   action :enable
  #   reload :delayed
  #   variables :script => "#{source_path}/example/wrapper.sh", :pidfilename => stop_key
  #   template_cookbook 'solr'
  #   template_source 'monit.conf.erb'
  # end
end

private
def exists?(source_path)
  ::File.exist?(source_path) && ::File.directory?(source_path)
end

def source_url_for_version(version)
  "https://archive.apache.org/dist/lucene/solr/#{version}/apache-solr-#{version}.tgz"
end
