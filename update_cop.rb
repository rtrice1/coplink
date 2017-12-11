require 'mysql2'
require 'active_record'
require 'active_record/diff'
require 'json'
require 'rest-client'
require 'optparse'
require 'yaml'
# Load the config file
config = YAML.load_file('config/application.yml')
$config = config['production']
require_relative 'lib/copdata'
require_relative 'lib/location'
require_relative 'lib/criticalspares'
require_relative 'lib/criticalspareinventorydata'

options = {}
options[:verbose] = false
options[:dryrun] = false
OptionParser.new do |opts|
	  opts.banner = "Usage: update_cop.rb [options]"
    opts.on("-v", "--verbose", "Run verbosely, i.e. gimme debug") do |v|
	    options[:verbose] = v
	  end
	  opts.on("-n", "--dry-run", "Don't make changes") do |n|
	    options[:dryrun] = n
	  end
end.parse!

$debug  = options[:verbose]
$dryrun = options[:dryrun]

ActiveRecord::Base.establish_connection(
    :adapter=> $config['adapter'],
    :host => $config['host'],
    :database=> $config['database'],
    :username => $config['db_user'],
    :password => $config['db_pass'],
    :port => $config['db_port'])
ActiveRecord::Base.connection.execute("call GetCriticalSpareDiffs();")
ActiveRecord::Base.connection.execute("call GetPodataCriticalSpareDiffs();")


CriticalSparesChanges.find_each do |part|
  if $debug then puts "Critical Spares " + part.operation + " part: " + part.UNIQUEPARTID end
  success = false;
  new_cs = CriticalSpareInventoryData.new(part,$dryrun)
  if      part.operation == 'add'    then id = new_cs.create; if id != "0" then part.cop_id = id; success = true  end
    elsif part.operation == 'update' then success = new_cs.update(part.cop_id)
    elsif part.operation == 'delete' then success = new_cs.delete(part.cop_id)
    else  raise "Part in Changes table with no CRUD operation.  Part ID: " + part.UNIQUEPARTID
  end
  if success then
     begin
     if !$dryrun then
       if    part.operation == 'add'    then
          cs = CriticalSpares.create(part.attributes.except("operation"))
          history = CriticalSparesChangeHistory.create(part.attributes)
       elsif part.operation == 'update' then
          cs = CriticalSpares.find(part.UNIQUEPARTID)
	  if $debug then puts "changes for part: " + cs.diff(part).to_s end
          cs.assign_attributes(part.attributes.except("operation"))
          cs.save
          history = CriticalSparesChangeHistory.create(part.attributes)
       else
         cs = CriticalSpares.find(part.UNIQUEPARTID)
         cs.destroy
         history = CriticalSparesChangeHistory.create(part.attributes)
       end
     end
     rescue StandardError => e
       puts "There was an error " + part.operation + "ing part: " + part.cop_id
       puts e
     end
  end
end

require_relative 'lib/podatacriticalspares'
require_relative 'lib/podatacriticalspareinventorydata'

PodataCriticalSparesChanges.find_each do |part|
  if $debug then puts "Open Orders " + part.operation + " part: " + part.podata_id end
  success = false;
  new_cs = PodataCriticalSpareInventoryData.new(part,$dryrun)
  if      part.operation == 'add'    then id = new_cs.create; if id != "0" then part.cop_id = id; success = true  end
    elsif part.operation == 'update' then success = new_cs.update(part.cop_id)
    elsif part.operation == 'delete' then success = new_cs.delete(part.cop_id)
    else  raise "Part in Changes table with no CRUD operation.  Part ID: " + part.podata_id
  end
  if success then
     begin
     if !$dryrun then
       if    part.operation == 'add'    then
          cs = PodataCriticalSpares.create(part.attributes.except("operation"))
          history = PodataCriticalSparesChangeHistory.create(part.attributes)
       elsif part.operation == 'update' then
          cs = PodataCriticalSpares.find(part.podata_id)
	  if $debug then puts "changes for part: " + cs.diff(part).to_s end
          cs.assign_attributes(part.attributes.except("operation"))
          cs.save
          history = PodataCriticalSparesChangeHistory.create(part.attributes)
       else
         cs = PodataCriticalSpares.find(part.podata_id)
         cs.destroy
         history = PodataCriticalSparesChangeHistory.create(part.attributes)
       end
     end
     rescue StandardError => e
       puts "There was an error " + part.operation + "ing part: " + part.podata_id
       puts e
     end
  end
end
