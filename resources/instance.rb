actions :setup

attribute :identifier, :kind_of => String, :required => true, :name_attribute => true
attribute :home, :kind_of => String, :default => '/usr/local/lib/solr'
attribute :start_port, :kind_of => Integer, :required => true
attribute :stop_port, :kind_of => Integer, :required => true
attribute :stop_key, :kind_of => String, :required => true
attribute :owner, :kind_of => String, :default => 'root'
attribute :group, :kind_of => String, :default => 'root'
attribute :system_wide, :kind_of => [TrueClass, FalseClass], :default => false
attribute :version, :kind_of => String, :equal_to => ['4.0.0', '3.3.0', '1.4.1'], :default => '4.0.0'
attribute :data_dir, :kind_of => String, :default => '/var/lib/solr'
attribute :multicore, :kind_of => [TrueClass, FalseClass], :default => false
attribute :newrelic_jar_url, :kind_of => String
attribute :newrelic_template_cookbook, :kind_of => String
attribute :core_template_cookbook, :kind_of => String
