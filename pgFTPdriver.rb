

# coding: utf-8

# a super simple FTP server with hard coded auth details and only two files
# available for download.
#
# Usage:
#

require 'pg'

class PgFTPDriver
  
attr_accessor :current_dir  

  def change_dir(path, &block)
    
  begin
       conn = connecttodb() 
    
       conn.prepare('stmt2','select name from folder where name=$1')
    
       res = conn.exec_prepared('stmt2',[path])
               
         if res.count == 1
           
           currentdir(path)
           
           puts current_dir
           
           yield true           
         
         else   
         
          yield false         
          
             
         end   
    
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
    
       res = conn.exec_prepared('stmt6',[path,current_dir||"/"])    
           
           yield true                   
         
    rescue Exception => e
      
      puts e.message
      
    ensure
      closedb(conn)
    
    end
    
  end
  
  def authenticate(user, pass, &block)
      
   begin
       conn = connecttodb() 
    
       conn.prepare('stmt1','select name,pass from test where name=$1 and pass=$2')
    
       res = conn.exec_prepared('stmt1',[user,pass])
    
           
         if res.count == 1
           yield true
           
         else                    
         
          yield false         
          
             
         end   
    
    rescue Exception => e
      
      puts e.message
      
    ensure
      closedb(conn)
    
    end
  end
  
  def put_file(path, data, &block)
    
    begin
       conn = connecttodb() 
    
       conn.prepare('stmt1','insert into file (name,data,pnmae) values ($1,$2,$3)')
    
       res = conn.exec_prepared('stmt1',[path,data,current_dir||"/"])
    
           if res.count == 1
           yield true
           
         else                    
         
          yield false         
          
             
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
 
  def dir_contents(path, &block)
     
  
    begin
         conn = connecttodb()     
           
       
          conn.prepare('stmt4','select name from folder where pname=$1')
       
          conn.prepare('stmt5', 'select name,data from file where pnmae=$1')    
        
       
          res2 = conn.exec_prepared('stmt4',[path])
          
          res3 = conn.exec_prepared('stmt5',[path])          
                             
                   
               yield [ dir_item(res2.getvalue(0,0)) ]
                     
                         
    
    rescue Exception => e
      
      puts e.message
      
    ensure
      closedb(conn)
    
    end    
   
   
     
  end
  
  def get_file(path, &block)
     begin
       conn = connecttodb() 
    
       conn.prepare('stmt1','select name,data from file where name=$1')
    
    puts path
    
       res = conn.exec_prepared('stmt1',[path])
       
       
          data = res.getvalue(0,1)
          
          if File.exist?("/home/harssh/Documents"+path)
            

             file = File.open("/home/harssh/Documents"+path, "w")
          
             file.write("#{data}") 
             
          else
           
              File.new("/home/harssh/Documents"+path, "w")

              file = File.open("/home/harssh/Documents"+path, "w")
          
              file.write("#{data}") 
          end
                
                     
                     yield true
                     
          
                     
    rescue Exception => e
      
      puts e.message
      
    ensure
      
      closedb(conn)
      
      file.close unless file == nil
          
           
       
      
    end
    
  end
 
  def bytes(path, &block)
    
    begin
       conn = connecttodb() 
    
       conn.prepare('stmt1','select length(data) from file where pnmae=$1')              
    
       res = conn.exec_prepared('stmt1',[path])
    
       fcontent = res.getvalue(0,0)
       
       yield fcontent
        
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

  def file_item(name)
    EM::FTPD::DirectoryItem.new(:name => name, :directory => false, :size => 0)
 
  end
  
  def connecttodb()
    PGconn.new('localhost', 5432, '', '', 'test', 'postgres', '123456') 
  end

  def closedb(conn)
    if !conn.nil?
      conn.close
    end
    
  end

def currentdir(path)
  
  @current_dir = path

  puts current_dir
  
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