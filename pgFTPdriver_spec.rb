

require 'pg'

       
        
describe "pgFTPdriver" do

  
  describe "Authenticate" do
    
    it "should connect to db" do
     
     
        conn = connecttodb()
        
        conn.should_not be_nil                
      
        
      end
      
      
      it "should get value in resulset" do
        
        conn = connecttodb() 
        
        conn.prepare('stmt1','select name,pass from test where name=$1 and pass=$2')
    
        res = conn.exec_prepared('stmt1',['12345','12345'])
        
        res.should_not be_nil
        
      end
      
    end
    
    
  
  describe "make dir" do
    
     it "should get list of dirs" do
       
       conn = connecttodb() 
       
       conn.prepare('stmt4','select name from folder where pname=$1')
       
             
       
        res2 = conn.exec_prepared('stmt4',['/'])
          
                             
        res2.count.should_not be_nil   
  
  
     end
  
  
  end
  
    
    def connecttodb()
    PGconn.new('localhost', 5432, '', '', 'test', 'postgres', '123456') 
    end 
    
    
  end
 
  

