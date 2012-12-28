

# coding: utf-8

# a super simple FTP server with hard coded auth details and only two files
# available for download.
#
# Usage:
#

require 'pg'

class PgFTPDriver
  FILE_ONE = "This is the first file available for download.\n\nBy James"

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
    
  when "/" then
    
      begin
         conn = connecttodb() 
    
        
       
         conn.prepare('stmt4','select name from folder where pname=$1')
       
         conn.prepare('stmt5', 'select name from file where pnmae=$1')
    
          
       
          res2 = conn.exec_prepared('stmt4',[path])
          
          res3 = conn.exec_prepared('stmt5',[path])
          
              
          
               res2.each do |row|
                 
                 rvalue = res2.getvalue(0,0)
                
             yield [ dir_item(rvalue) ]
             
             res3.each do |row1|
              yield [ file_item(row1) ]
          end
          end
      
              
      
                   
    rescue Exception => e
      
      puts e.message
      
    ensure
      closedb(conn)
    
    end  
    
  when path then
    
    begin
         conn = connecttodb() 
    
         conn.prepare('stmt3','select name from folder where name=$1')    
       
         conn.prepare('stmt4','select name from folder where pname=$1')
       
         conn.prepare('stmt5', 'select name from file where pnmae=$1')
    
          res1 = conn.exec_prepared('stmt3',[path])
       
          res2 = conn.exec_prepared('stmt4',[path])
          
          res3 = conn.exec_prepared('stmt5',[path])
          
              
          res1.each do |row|
             yield [ dir_item(row) ]
          end
           
           res2.each do |row|
             yield [ dir_item(row) ]
              res3.each do |row1|
             yield [ file_item(row1) ]
          end
          end
      
             
      
                   
    rescue Exception => e
      
      puts e.message
      
    ensure
      closedb(conn)
    
    end   
    
    else
      
      yield[]
      
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
    
    begin
       conn = connecttodb() 
    
       conn.prepare('stmt1','select content from file where name=$1 ')
              
    
       res = conn.exec_prepared('stmt1',[path])
    
       fcontent = res.getvalue(0,0)
       
       puts fcontent
           
        yield fcontent.size()
        
    rescue Exception => e
      
      puts e.message
      
    ensure
      closedb(conn)
    
    end
   
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
  
  def connecttodb()
    PGconn.new('localhost', 5432, '', '', 'test', 'postgres', '123456') 
  end

  def closedb(conn)
    if !conn.nil?
      conn.close
    end
    
  end
  
  def dir_structure(path)
    begin
       conn = connecttodb() 
    
       conn.prepare('stmt3','select name from folder where name=$1')
      
       conn.prepare('stmt4','select name from folder where pname=$1')
       
       conn.prepare('stmt5', 'select name from file where pnmae=$1')
       
    #conn.prepare('stmt4','select name from file where foid is (select foid from folder where name=$1)')
    
       res1 = conn.exec_prepared('stmt3',[path])
       
       res2 = conn.exec_prepared('stmt4',[path])
       
       res3 = conn.exec_prepared('stmt5',[path])
    
        
    
      res1.each do |row|
        
        yield [ dir_item(row)]
        
      end
        
        res2.each do |row|
          
          yield [dir_item(row)]
      
        end      
      
        res3.each do |row|
          
          yield [ file_item(row) ]
          
        end   
   
    rescue Exception => e
      
      puts e.message
      
    ensure
      closedb(conn)
    
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