# coding: utf-8

# a super simple FTP server with hard coded auth details and only two files
# available for download.
#
# Usage:
#

require 'pg'

class PgFTPDriver
  FILE_ONE = "This is the first file available for download.\n\nBy James"
  FILE_TWO = "This is the file number two.\n\n2009-03-21"

  def change_dir(path, &block)
  
  end

  def dir_contents(path, &block)
   
  end



  def authenticate(user, pass, &block)
      
    conn = connect('test','postgres','123456')
 
    
    conn.prepare('stmt1','select name,pass from test where name=$1 and pass=$2')
    
    res = conn.exec_prepared('stmt1',['test','1234'])
    
         if res[0].nil?
         yield false
        else                    
         
       yield true         
          return     
    end
  end

   


  def bytes(path, &block)
   yield false
  end

  def get_file(path, &block)
    yield false
  end

  def put_file(path, data, &block)
    yield false
  end

  def delete_file(path, &block)
    yield false
  end

  def delete_dir(path, &block)
    yield false
  end

  def rename(from, to, &block)
    yield false
  end

  def make_dir(path, &block)
    yield false
  end

  private

  def dir_item(name)
    EM::FTPD::DirectoryItem.new(:name => name, :directory => true, :size => 0)
  end

  def file_item(name, bytes)
    EM::FTPD::DirectoryItem.new(:name => name, :directory => false, :size => bytes)
  end
  
  
  def connect(db, user, pw)
  PGconn.new('localhost', 5432, '', '', db, user, pw) 
  end

end

# configure the server
#driver FakeFTPDriver
#driver_args 1, 2, 3
#user "ftp"
#group "ftp"
#daemonise false
#name "fakeftp"
#pid_file "/var/run/fakeftp.pid"