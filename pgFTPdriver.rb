
require 'pg'
require 'em-ftpd'
require 'eventmachine'

class PgFTPDriver
  
attr_accessor :current_dir ,:current_dirid,:dirlis,:dirlist

  def change_dir(path, &block)
    
  begin
       conn = connecttodb() 
       puts "changing dir to : "+path
       conn.prepare('stmt2','select name,foid from folders where pname=$1 and name=$2')
    
       res = conn.exec_prepared('stmt2',[current_dirid||'1',path])
               
         if res.count == 1
           
           currentdir(path,res.getvalue(0,1))
                      
           puts "Current dir is : "+current_dir
           
           puts "Current dir id is : "+current_dirid
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
   
   newdirname = path.match(/([^\/.]*)$/)
   
   ndirname = "/"+newdirname[0]
   
    begin
      
       conn = connecttodb() 
       puts path
      
       conn.prepare('stmt6','insert into folders (name,pname) values ($1,$2)')
              
       res = conn.exec_prepared('stmt6',[ndirname,current_dirid||'1'])    
           
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
    
       conn.prepare('stmt1','insert into files (name,data,pname) values ($1,$2,$3)')
    
       res = conn.exec_prepared('stmt1',[path,data,current_dirid||"1"])    
          
           yield true                   
          
    rescue Exception => e
      
      puts e.message
      
    ensure
      closedb(conn)
    
    end
    
  end

  def delete_file(path, &block)
   begin
       conn = connecttodb() 
    
       conn.prepare('stmt6','delete from files where name=$1 and pname=$2')
                  
       res4 = conn.exec_prepared('stmt6',[path,current_dirid||'1'])
       
            yield true           
         
    rescue Exception => e
      
      puts e.message
      
    ensure
      closedb(conn)
    
    end
    
  end

  def delete_dir(path, &block)
   
    begin
    puts path
       conn = connecttodb()      
       
       conn.prepare('stmt9','select foid from folders where name=$1 and pname=$2')
    
       conn.prepare('stmt6','delete from folders where name=$1 and pname=$2')
       
       conn.prepare('stmt7','delete from folder where pname=$1')
      
       res9 = conn.exec_prepared('stmt9',[path,current_dirid||'1'])
    
       res6 = conn.exec_prepared('stmt6',[path,current_dirid||'1'])
       
       
       parent_id = res9.getvalue(0,0)
       
       res7 = conn.exec_prepared('stmt7',[parent_id])     
       
           
           yield true         
          
         
    rescue Exception => e
      
      puts e.message
      
    ensure
      closedb(conn)
    
    end
    
  end
 
  def dir_contents(path, &block)
     
  case path
    
  when "/" then    
    
  path =  "/"+path.tr('^A-Za-z0-9.', '')
  
  puts "contents of : "+path
    begin
          conn = connecttodb()     
                     
          conn.prepare('stmt4','select name from folders where pname=$1')
             
          conn.prepare('stmt5', 'select name,data from files where pname=$1')    
                
          res2 = conn.exec_prepared('stmt4',[current_dirid||'1'])
          
          res3 = conn.exec_prepared('stmt5',[current_dirid||'1'])          
                         
              
               @dirlist = Array.new
                  k =0                         
            
               res2.each do |row1|                                 
                  val = res2.getvalue(k,0)                                 
               
                  val = val.tr('^A-Za-z0-9.', '')
               
                  @dirlist[k] = dir_item(val)                  
                                        
                  k = k+1                  
               end 
                                         
               
                res3.each_with_index do |row2,m|
                                 
                  val = res3.getvalue(m,0)                                    
                      
                    val = val.tr('^A-Za-z0-9.', '')
               
                 
                  @dirlist[k] = file_item(val,'20')
                     
                  m = m+1                      
                  k = k+1
                  
               end           
           
            yield [ *dirlist ]               
           
          
    rescue Exception => e
      
      puts e.message
      
    ensure
      
      closedb(conn)
    
    end       
     
     when path then    
    
        path =  "/"+path.tr('^A-Za-z0-9.', '')
  
        puts "contents of : "+path
    begin
          conn = connecttodb()     
                     
          conn.prepare('stmt4','select name from folders where pname=$1')
             
          conn.prepare('stmt5', 'select name,data from files where pname=$1')    
                
          res2 = conn.exec_prepared('stmt4',[current_dirid||'1'])
          
          res3 = conn.exec_prepared('stmt5',[current_dirid||'1'])          
                         
              
               @dirlist = Array.new
                  k =0                         
            
               res2.each do |row1|                                 
                  val = res2.getvalue(k,0)                                 
                      
                   val = val.tr('^A-Za-z0-9.', '')
                  @dirlist[k] = dir_item(val)                  
                                        
                  k = k+1                  
               end 
                                         
               
                res3.each_with_index do |row2,m|
                                 
                  val = res3.getvalue(m,0)    
                   val = val.tr('^A-Za-z0-9.', '')                                
                      
                  @dirlist[k] = file_item(val,'20')
                     
                  m = m+1                      
                  k = k+1
                  
               end           
           
            yield [ *dirlist ]               
           
          
    rescue Exception => e
      
      puts e.message
      
    ensure
      
      closedb(conn)
    
    end       
   else
     
      yield []
      
      end        
     
  end
  
  def get_file(path, &block)
     begin
       conn = connecttodb() 
    
       conn.prepare('stmt1','select name,data from files where name=$1 and pname=$2')
    
    puts "getting file from : "+path
    
       res = conn.exec_prepared('stmt1',[path,current_dirid||'1'])       
       
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
    
       conn.prepare('stmt1','select length(data) from files where name=$1')              
    
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

  def file_item(name,bytes)
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

def currentdir(path,id)
  
  @current_dir = path
  @current_dirid = id
  
  
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