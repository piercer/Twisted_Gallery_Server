require 'rubygems'
require 'mysql'
require 'yaml'

class DBHandler

  def initialize
    config = YAML::load_file("config.yml")
    @dbh=Mysql.init
    @dbh.query_with_result=false
    @dbh.real_connect(config['server'], config['user'], config['password'], config['database'],config['port'],nil,Mysql::CLIENT_MULTI_RESULTS)
  end  

  def query(sql)
    @dbh.query(sql)
    @dbh.use_result
  end
  
  def next_result
    @dbh.next_result
    @dbh.use_result
  end
  
  def close
    clear
   # @dbh.close
  end

  def clear
    more_results=true;
    begin
      @dbh.next_result
      while more_results
        @dbh.use_result.each { |row| }
        @dbh.next_result
      end
    rescue Mysql::Error => e
      more_results=false
    end
  end

end