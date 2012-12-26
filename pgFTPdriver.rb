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
    yield path == "/" || path == "/files"
  end

  def dir_contents(path, &block)
    case path
    when "/" then
      yield [ dir_item("files"), file_item("one.txt", FILE_ONE.bytesize) ]
    when "/files" then
      yield [ file_item("two.txt", FILE_TWO.bytesize) ]
    else
      yield []
    end
  end

def connect(db, user, pw)
  PGconn.new('localhost', 5432, '', '', db, user, pw) 
end

  def authenticate(user, pass, &block)
  #  conn = PG::connection.open(:dbname => 'test')
   # userArray = []
  # PGconn.new('localhost', 5432, test, postgres, 123456)
   # conn = PGconn.open(:dbname => 'test')
    
    conn = connect('test','postgres','')
    
     res = conn.exec('select * from test')
    
    res.each do |p|
        if user == p[0][1] && pass == p[0][2] #to checking correct username & password
         yield true
          return
            end
               end
      yield false 
    #yield user == "test" && pass == "1234"
  end

   # def self.find
     # res[]
     # conn = PG::connection.open(:dbname => 'test')
     # res = conn.exex('select * from user')
   # end



  def bytes(path, &block)
    yield case path
          when "/one.txt" then FILE_ONE.size
          when "/files/two.txt" then FILE_TWO.size
          else
            false
          end
  end

  def get_file(path, &block)
    yield case path
          when "/one.txt" then FILE_ONE
          when "/files/two.txt" then FILE_TWO
          else
            false
          end
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

end

# configure the server
#driver FakeFTPDriver
#driver_args 1, 2, 3
#user "ftp"
#group "ftp"
#daemonise false
#name "fakeftp"
#pid_file "/var/run/fakeftp.pid"