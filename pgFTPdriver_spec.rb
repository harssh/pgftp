

require 'pg'

        conn = PGconn.new('localhost', 5432, '', '', 'test', 'postgres', '123456')
        
describe "pgFTPdriver" do

  
  describe "Authenticate" do
    
    it "should connect to db" do
     
     
        conn = PGconn.new('localhost', 5432, '', '', 'test', 'postgres', '123456')      
        
        conn.should_not be_nil                
      
        
      end
      
      
      it "should get value in resulset" do
        
        conn = PGconn.new('localhost', 5432, '', '', 'test', 'postgres', '123456') 
        
        conn.prepare('stmt1','select name,pass from test where name=$1 and pass=$2')
    
        res = conn.exec_prepared('stmt1',['12345','12345'])
        
        res.should_not be_nil
        
      end
      
    end
    
     describe "bytes" do
    
     it "should get file content in resultset" do          
             
       
        conn = PGconn.new('localhost', 5432, '', '', 'test', 'postgres', '123456')
        
        conn.prepare('stmt2','select content from file where name=$1 ')
    
        res = conn.exec_prepared('stmt2','\documents')
         
        res.should_not be_nil
         
    end
    
  end
    
    
  end
 
  

