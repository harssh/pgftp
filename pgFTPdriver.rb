

# coding: utf-8

# a super simple FTP server with hard coded auth details and only two files
# available for download.
#
# Usage:
#

require 'pg'

class PgFTPDriver
  

  def change_dir(path, &block)
    
  begin
       conn = connecttodb() 
    
       conn.prepare('stmt2','select name from folder where name=$1')
    
       res = conn.exec_prepared('stmt2',[path])
               
         if res.count == 1
           yield true
           return
         
         else   
         
          yield false         
          return
             
         end   
    
    rescue Exception => e
      
      puts e.message
      
    ensure
      closedb(conn)
    
    end
  end

  def dir_contents(path, &block)
    
  case path    
  
  when path then
    
    begin
         conn = connecttodb()     
           
       
          conn.prepare('stmt4','select name from folder where pname=$1')
       
          conn.prepare('stmt5', 'select name from file where pnmae=$1')    
        
       
          res2 = conn.exec_prepared('stmt4',[path])
          
          res3 = conn.exec_prepared('stmt5',[path])
          
                             
           if res2.count != 0 || res3.count != 0 
            
           res2.each do |row|
             yield [ dir_item(row) ]
           end
      
         res3.each do |row1|
             yield [ file_item(row1) ]
         end
         
         
         else 
            yield false
      
         end
      
                   
    rescue Exception => e
      
      puts e.message
      
    ensure
      closedb(conn)
    
    end   
    
    else
      
      yield false
      
   end
     
  end

  def authenticate(user, pass, &block)
      
   begin
       conn = connecttodb() 
    
       conn.prepare('stmt1','select name,pass from test where name=$1 and pass=$2')
    
       res = conn.exec_prepared('stmt1',[user,pass])
    
           
         if res.count == 1
           yield true
           return
         else                    
         
          yield false         
          return
             
         end   
    
    rescue Exception => e
      
      puts e.message
      
    ensure
      closedb(conn)
    
    end
  end

  def bytes(path, &block)
    
    yield true
   
  end

  def get_file(path, &block)
    yield false
  end

  def put_file(path, data, &block)
    
    begin
       conn = connecttodb() 
    
       conn.prepare('stmt1','insert into file values ($1,$2)')
    
       res = conn.exec_prepared('stmt1',[path,data])
    
           if res.count == 1
           yield true
           return
         else                    
         
          yield false         
          return
             
         end   
    rescue Exception => e
      
      puts e.message
      
    ensure
      closedb(conn)
    
    end
    
  end

  def delete_file(path, &block)
   begin
       conn = connecttodb() 
    
       conn.prepare('stmt6','delete from file where name=$1')
              
    
      res4 = conn.exec_prepared('stmt6',[path])
       
       
           
           yield true
         
          
         
    rescue Exception => e
      
      puts e.message
      
    ensure
      closedb(conn)
    
    end
    
  end

  def delete_dir(path, &block)
    begin
       conn = connecttodb() 
    
       conn.prepare('stmt6','delete from folder where name=$1')
       
       conn.prepare('stmt7','delete from folder where pname=$1')
       
    
       res4 = conn.exec_prepared('stmt6',[path])
       
       res5 = conn.exec_prepared('stmt7',[path])
       
           
           yield true
         
          
         
    rescue Exception => e
      
      puts e.message
      
    ensure
      closedb(conn)
    
    end
    
  end
 
  def make_dir(path, &block)
    begin
       conn = connecttodb() 
    
       conn.prepare('stmt6','insert into folder (name,pname) values ($1,$2)')
    
       res = conn.exec_prepared('stmt6',[path,'/'])
    
           
           yield true
         
          
         
    rescue Exception => e
      
      puts e.message
      
    ensure
      closedb(conn)
    
    end
    
  end

private

  def dir_item(name)
    EM::FTPD::DirectoryItem.new(:name => name, :directory => true, :size => 0)
  end

  def file_item(name, bytes)
    EM::FTPD::DirectoryItem.new(:name => name, :directory => false, :size => bytes)
 
  end
  
  def connecttodb()
    PGconn.new('localhost', 5432, '', '', 'test', 'postgres', '123456') 
  end

  def closedb(conn)
    if !conn.nil?
      conn.close
    end
    
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