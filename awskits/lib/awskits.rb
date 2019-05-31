Dir[File.join(File.dirname(__FILE__), 'awskits/*.rb')].sort.each { |lib| require lib }

$BASE_DIR = File.expand_path(File.dirname(__FILE__)) + "/../"
