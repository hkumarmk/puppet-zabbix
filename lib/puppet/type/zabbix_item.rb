require 'puppet/util/zabbix'

Puppet::Type.newtype(:zabbix_item) do

  @doc = %q{Manage zabbix items

    Example.
      Zabbix_item {
        zabbix_url => 'zabbix_server1',
        zabbix_user => 'admin',
        zabbix_pass => 'zabbix',
      }

      zabbix_item{"app1@host1":
        ensure  => present,
        enable  => true,
        key     => 'app1',
        delay   => 10,
        history => 60,
        trends  => 90,
        type    => 'zabbix_agent'
      }

  }

  def self.title_patterns
    [ [ /^(.*)@(.*)$/, [ [ :name, lambda{|x| x} ], [:host, lambda{|x| x}] ] ] ]
  end

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc 'item name'
  end

  newparam(:host, :namevar => true) do
    desc 'Host or Template name this item belong to'
  end

  newparam(:key) do
    desc 'Item key'
    defaultto {@resource[:name]}
  end

  newparam(:description) do
    desc 'Item description'
  end

  newproperty(:delay) do
    desc 'Update interval of the item in Seconds'
    newvalues(/^\d+$/)
    defaultto 60
    munge do |v|
        v.to_s
    end
  end

  newproperty(:history) do
    desc 'Number of days to keep item\'s history data'
    newvalues(/^\d+$/)
    defaultto 60
  end

  newproperty(:trends) do
    desc 'Number of days to keep item\'s trends data'
    newvalues(/^\d+$/)
    defaultto 365
  end

  newparam(:applications, :array_matching => :all) do
    desc 'Applications to which this item linked to'

    def insync?(is)
      is.sort == should.sort
    end
  end

  newproperty(:enable, :boolean => true) do
    desc 'Whether enable or disable the item'
    newvalues(:true, :false)
    defaultto true

    munge do |v|
      vals = {true => 0, false => 1}
      vals[v].to_s
    end

    def is_to_s(currentvalue)
      vals = {'0' => true, '1' => false}
      vals[currentvalue]
    end

    def should_to_s(newvalue)
      vals = {'0' => true, '1' => false}
      vals[newvalue]
    end
  end

  newproperty(:type) do
    desc 'Type of the item'
    newvalues(
      :zabbix_agent,     #0
      :snmpv1,           #1
      :zabbix_trapper,   #2
      :simple,           #3
      :snmpv2,           #4
      :zabbix_internal,  #5
      :snmpv3,           #6
      :zabbix_active,    #7
      :zabbix_aggregate, #8
      :web,              #9
      :external,         #10
      :database,         #11
      :ipmi,             #12
      :ssh,              #13
      :telnet,           #14
      :calculated,       #15
      :jmx,              #16
      :snmp_trap         #17
    )
    defaultto 'zabbix_active'

    munge do |v|
      vals = {
        'zabbix_agent' => 0, 'snmpv1' => 1, 'zabbix_trapper' => 2,
        'simple' => 3, 'snmpv2' => 4, 'zabbix_internal' => 5,
        'snmpv3' => 6, 'zabbix_active' => 7, 'zabbix_aggregate' => 8,
        'web' => 9, 'external' => 10, 'database' => 11, 'ipmi' => 12,
        'ssh' => 13, 'telnet' => 14, 'calculated' => 15, 'jmx' => 16,
        'snmp_trap' => 17 }
      vals[v]
    end
  end

  newproperty(:snmp_community) do
    desc "SNMP Community"
    newvalues(/\S+/)
  end

  newparam(:snmp_oid) do
    desc 'SNMP OID'
    newvalues(/\S+/)
  end

  newparam(:value_type) do
    desc 'Type of information of the item.'
    newvalues(
      :float,   #0
      :char,    #1
      :log,     #2
      :int,     #3
      :text,    #4
    )
    defaultto 'int'

    munge do |v|
      vals = {'float' => 0, 'char' => 1, 'log' => 2, 'int' => 3, 'text' => 4}
      vals[v]
    end
  end

  newparam(:data_type) do
    desc 'Data type of the item'
    newvalues(
      :decimal, #0
      :octal,   #1
      :hex,     #2
      :bool,    #3
    )
    defaultto 'decimal'

    munge do |v|
        vals = {'decimal' => 0, 'octal' => 1, 'hex' => 2, 'bool' => 3}
        vals[v]
    end
  end

  newparam(:trapper_hosts) do
    desc 'Allowed hosts. Used only by trapper items.'
    newvalues(/\S+/)
  end

  newparam(:snmp_port) do
    desc 'SNMP Port'
    newvalues(/\d+/)
    defaultto 161
  end

  newparam(:units) do
    desc 'Value units.'
    newvalues(/\S+/)
  end

  newparam(:multiplier) do
    desc 'custom multiplier.'
    newvalues(/\d+/)
    defaultto 0
  end

  newparam(:delta) do
    desc 'Value that will be stored.'
    newvalues(
      :asis,   #0
      :speed_persec, #1
      :simple_change, #2
    )

    defaultto 'asis'
    munge do |v|
      vals = {'asis' => 0, 'speed_persec' => 1, 'simple_change' => 2}
      vals[v]
    end
  end

  newparam(:snmpv3_securityname) do
    desc 'SNMP V3 Security name'
    newvalues(/\S+/)
  end

  newparam(:snmpv3_securitylevel) do
    desc 'SNMP V3 security level'
    newvalues(
      :noauth_nopriv, #0
      :auth_nopriv,   #1
      :authpriv,      #2
    )
    defaultto 'noauth_nopriv'
    munge do |v|
      vals = {'noauth_nopriv' => 0, 'auth_nopriv' => 1, 'authpriv' => 2}
      vals[v]
    end
  end

  newparam(:snmpv3_authpassphrase) do
    desc 'SNMP V3 authpassphrase'
    newvalues(/\S+/)
  end

  newparam(:snmpv3_privpassphrase) do
    desc 'SNMP V3 Priv passphrase'
    newvalues(/\S+/)
  end

  newparam(:logtimefmt) do
    desc 'Format of the time in log entries. Used only by log items.'
  end

  Puppet::Util::Zabbix.add_zabbix_type_methods(self)

end

