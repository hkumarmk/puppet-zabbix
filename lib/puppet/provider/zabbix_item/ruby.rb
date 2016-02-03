require File.expand_path(File.join(File.dirname(__FILE__), '..', 'zabbix'))
Puppet::Type.type(:zabbix_item).provide(:ruby, :parent => Puppet::Provider::Zabbix) do

  def connect
    if @resource[:zabbix_url] != ''
      self.class.require_zabbix
    end

    @zbx ||= self.class.create_connection(@resource[:zabbix_url],@resource[:zabbix_user],@resource[:zabbix_pass],@resource[:apache_use_ssl])
    return @zbx
  end

  def host_or_template_id
    zbx = connect
    @host_or_template_id ||= (zbx.hosts.get_id(:host => @resource[:host]) || zbx.templates.get_id(:host => @resource[:host]))
    raise(Puppet::Error, "The host \"#{@resource[:host]}\" does not exists") unless @host_or_template_id
    return @host_or_template_id
  end

  def item_data
    zbx = connect
    return @item_data ||= zbx.items.get_full_data(:name => @resource[:name]).select{|i| i['hostid'].to_s.eql?(host_or_template_id.to_s)}.fetch(0,{})
  end

  def item_data_update
    return @item_data_update ||= {:itemid => item_id}
  end

  def item_id
    zbx = connect
    return item_data.fetch('itemid',nil)
  end

  def app_ids
    zbx = connect
    @app_ids ||= @resource[:applications].inject([]){|memo, name| memo << zbx.applications.get_id(:name => name)}
  end

  def create
    puts "Creating - #{@resource[:name]}, #{@resource[:key]}, #{@resource[:host]}"
    zbx = connect
    zbx.items.create(
      :name   => @resource[:name],
      :description => @resource[:description],
      :key_ => @resource[:key],
      :type => @resource[:type],
      :value_type => @resource[:value_type],
      :hostid => host_or_template_id,
      :applications => app_ids,
      :delay => @resource[:delay],
      :history => @resource[:history],
      :trends => @resource[:trends],
      :snmp_oid => @resource[:snmp_oid],
      :data_type => @resource[:data_type],
      :trapper_hosts => @resource[:trapper_hosts],
      :snmp_port => @resource[:snmp_port],
      :units => @resource[:units],
      #:multiplier => @resource[:multiplier],
      :delta => @resource[:delta],
      :snmpv3_securityname => @resource[:snmpv3_securityname],
      :snmpv3_securitylevel => @resource[:snmpv3_securitylevel],
      :snmpv3_authpassphrase => @resource[:snmpv3_authpassphrase],
      :snmpv3_privpassphrase => @resource[:snmpv3_privpassphrase],
      :logtimefmt => @resource[:logtimefmt],
      :status => @resource[:enable],
    )
  end


  def exists?
    item_id
  end

  def destroy
    zbx = connect
    begin
        zbx.items.delete(item_id)
    rescue => error
        raise(Puppet::Error, "Zabbix Item Delete Failed\n#{error.message}")
    end
  end

  def enable
    item_data['status']
  end

  def enable=(value)
    item_data_update[:status] = value
  end

  def delay
    item_data['delay']
  end

  def delay=(value)
    item_data_update[:delay] = value
  end

  def history
    item_data['history']
  end

  def history=(value)
    item_data_update[:history] = value
  end

  def history=(value)
    item_data_update[:history] = value
  end

  def trends
    item_data['trends']
  end

  def trends=(value)
    item_data_update[:trends] = value
  end

  def type
    item_data['type']
  end

  def type=(value)
    item_data_update[:type] = value
  end

  def flush
    zbx = connect
    zbx.items.update(item_data_update)
  end


end
