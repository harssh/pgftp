
require 'pg'

class PgFTPDriver
  FILE_ONE = "This is the first file available for download.\n\nBy James"
attr_accessor :current_dir  ,:current_dirid

  def change_dir(path, &block)
    
  begin
       conn = connecttodb() 
    puts path
       conn.prepare('stmt2','select name,foid from folders where pname=$1 and name=$2')
    
       res = conn.exec_prepared('stmt2',[current_dirid||'1',path])
               
         if res.count == 1
           
           currentdir(path,res.getvalue(0,1))
           
           
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
       puts path
      
       # conn.prepare('stmt1','select foid from folders where name=$1')
#        
       # res1 = conn.exec_prepared('stmt1',[current_dir||'/'])
#        
#       
         # dirid = res1.getvalue(0,0)
      
       conn.prepare('stmt6','insert into folders (name,pname) values ($1,$2)')
              
    
       res = conn.exec_prepared('stmt6',[path,current_dirid||'1'])    
           
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
     
  case path
    
  when path then    
    
    begin
          conn = connecttodb()     
           
           
          conn.prepare('stmt4','select name from folders where pname=$1')
             
          conn.prepare('stmt5', 'select name,data from file where pnmae=$1')    
                
          res2 = conn.exec_prepared('stmt4',[current_dirid||'1'])
          
          res3 = conn.exec_prepared('stmt5',[current_dirid||'1'])          
                         
               folderlist = Array.new
               dirlist = Array.new
                                           
               res2.each_with_index do |row1,k|
                                 
                 val = res2.getvalue(k,0)
                 
                 fname = val.tr('^A-Za-z0-9', '')
                  
                  folderlist[k] = fname         
              
           
              
                 k = k+1
                  
                end       
              puts folderlist
               dirlist1 =  dir_item("files")
                  yield [ dirlist ]    
              
          
    rescue Exception => e
      
      puts e.message
      
    ensure
      closedb(conn)
    
    end    
   
   else
     
      yield true
      
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
    
       conn.prepare('stmt1','select length(data) from file where name=$1')              
    
       res = conn.exec_prepared('stmt1',[path])
    
       fcontent = res.getvalue(0,0)
       
       if res.count ==0
          yield true
     
        else
          
          yield false

       end
      
         
            return fcontent  
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