# Copyright (c) 2008 Peter Houghton 
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.


require 'rubygems'
require 'test/unit'
require 'errfix'
require 'eg_test_driver'

class StateModelCreator__tests < Test::Unit::TestCase

  # 1 Dimensional State tables
	TEST1_CSV="test1.csv"           # Simple 2 state 2 action table
	TEST2_1LINE_CSV="test2.csv"     # Only has 1 line
	TEST3_0LINE_CSV="test3.csv"     # Has no lines
	TEST4_CSV="test4.csv"           # Line with fork, UNIX format txt
	TEST5_CSV="test5.csv"           # Several states in a row, single file
	TEST9_CSV="test9.csv"           # Line with loop backs, DOS format txt
  TEST10_CSV="test10.csv"         # Line with fork, DOS format txt
  
  # 2 Dimensional State tables
  TEST1_2d_CSV="test1_2d.csv"           # Simple 2 state 2 action table
	TEST2_2d_1LINE_CSV="test2_2d.csv"     # Only has 1 line
	TEST3_2d_0LINE_CSV="test3_2d.csv"     # Has no lines
	TEST4_2d_CSV="test4_2d.csv"           # Line with fork, UNIX format txt
	TEST5_2d_CSV="test5_2d.csv"           # Several states in a row, single file
	TEST9_2d_CSV="test9_2d.csv"           # Line with loop backs, DOS Format txt
  TEST10_2d_CSV="test10_2d.csv"         # Line with fork, DOS format txt
	
	# DSL version of the above:  
	TEST9_DSL="test9_dsl.rb"           # Line with loop backs, DOS Format txt
	TEST10_DSL="test10_dsl.rb"  # Line with fork, DOS format txt
	
  
	def setup
	  @path = File.expand_path(File.dirname(__FILE__) + "/../test")
    @path = @path + "/"
    
    # For 1-Dimensional State tables
	  @valid_csv_files_1d=[@path + TEST1_CSV,@path + TEST4_CSV,@path + TEST10_CSV,@path + TEST9_CSV]
	  puts @valid_csv_files_1d
	  @valid_csv_files_states_1d=[2,5,5,5]
	  @valid_csv_files_transitions_1d=[2,4,4,8]
	  
	  # For 2-Dimensional State tables
	  @valid_csv_files_2d=[@path + TEST1_2d_CSV,@path + TEST4_2d_CSV,@path + TEST10_2d_CSV,@path + TEST9_2d_CSV]
	  puts @valid_csv_files_2d
	  @valid_csv_files_states_2d=[2,5,5,5]
	  @valid_csv_files_transitions_2d=[2,4,4,8]
	  
	  # For 1 and 2 Dimensional State tables
	  @valid_csv_files=@valid_csv_files_1d + @valid_csv_files_2d
	  puts @valid_csv_files
	  @valid_csv_files_states=[2,5,5,5,2,5,5,5]
	  @valid_csv_files_transitions=[2,4,4,8,2,4,4,8]
	  
	end # end setup method


  # Check that errfix can correctly detect whether the CSV represents
  # a 1 or 2 dimenional State table.
  #
  # 1 Dimensional
  def test_detect_state_table_one_dimensional    
    @valid_csv_files_1d.each do |csv_file|
      smc = StateModelCreator.new
	    dimensions = smc.detect_state_table_dim(csv_file)
      assert_equal(:one_d , dimensions ,"Check that one dimensional state tables are detected in #{csv_file}")
    end # end csv files		
  end # end test method
  
  # 2 Dimensional
  def test_detect_state_table_two_dimensional    
    @valid_csv_files_2d.each do |csv_file|
      smc = StateModelCreator.new
	    dimensions = smc.detect_state_table_dim(csv_file)
      assert_equal(:two_d , dimensions ,"Check that Two dimensional state tables are detected in #{csv_file}")
    end # end csv files		
  end # end test method


  # Neither 1 or 2 D, should raise RuntimrError
   def test_detect_state_table__empty_file    
 		assert_raises RuntimeError do
 			smc = StateModelCreator.new
 			puts "Next test_detect_state_table__empty_file: "
 			smc.detect_state_table_dim(@path + TEST3_0LINE_CSV)
 		end # Assert Raises	
  end # end test method

  def test_detect_state_table_missing_file
    # Missing CSV file
		assert_raises RuntimeError do
			smc = StateModelCreator.new
			smc.detect_state_table_dim("madeupname_that_just_aint_real.csv")
		end # Assert Raises
	end # end method

  # Check that load_table returns a copy of the state machine
  # This makes it easier and cleaner to use.
  def test_load_table_return
    
	  smc = StateModelCreator.new
    returned_obj = smc.load_table(@path + TEST1_CSV)

    assert( returned_obj.instance_of?(StateMachine) , "Check loadtable returns StateMachine, returns: #{returned_obj.class}" )
  end # end load_table test

	def test_state_store_general
		smc = StateModelCreator.new
	  sm = smc.load_table(@path + TEST1_CSV)
	  
		# Check that the states store is an array of strings
		assert_equal(Array.new.class,sm.states_store.class, "States Store is an Array")
		assert_equal(String.new.class ,sm.states_store[0].class, "States Store Array contains Strings")

		# Check that the correct number of states were added 
		assert(sm.states_store.length==2)

		# Check that the states store contains the 2 states in the csv	
		assert((sm.states_store[0]=="STATEA")||(sm.states_store[0]=="STATEB") , "States store pos 0 is A or B")	
		assert((sm.states_store[1]=="STATEA")||(sm.states_store[1]=="STATEB") , "States store pos 1 is A or B")
		assert((sm.states_store[0] != sm.states_store[1] ) , "States store, the states are not the same...")

	end # end test

  # Test that the to_s producs a string
  # Simple check that the correct Type of object is produced.
  # Tests should probably do a simple parse, for known words.
	def test_to_s
    @valid_csv_files.each do |csv_file|
		  smc = StateModelCreator.new
      sm = smc.load_table(csv_file)
      
		  assert_equal(String.new.class , sm.to_s.class , "Check that the to_s produces a string ok")
		  puts sm.to_s
		end # end csv files
	end # end test to_s

  # Get Actions For State
  # Check that the state returns correct actions
	def test_get_actions_for_state
		smc = StateModelCreator.new
		sm = smc.load_table(@path + TEST1_CSV)
		
		# Check that correct actions are returned
		assert_equal("action1",sm.get_actions_for_state("STATEA")[0],"Check first action is action1")
		assert_equal("action2",sm.get_actions_for_state("STATEB")[0],"Check second action is action2")	

	end # test end

	def test_check_state_table_store
	  @valid_csv_files.each_index do |index|
	    csv_file=@valid_csv_files[index]
	    
		  smc = StateModelCreator.new
		  sm = smc.load_table(csv_file)

		  # Check that Adjacency Matrix is ok, this is actually the adjacency matrix
		  assert_equal(Hash.new.class,sm.adjacency_matrix.class, "Check state is the right class in #{csv_file}.")
		  assert_equal(@valid_csv_files_states[index],sm.adjacency_matrix.keys.length, "Check correct number of states in #{csv_file}")

		  transition_obj=sm.adjacency_matrix.shift[1][0]
		  assert_equal(TransitionHolder.new.class , transition_obj.class, "Check hash is full of transitions in #{csv_file}")
		  assert_equal(String.new.class , transition_obj.start_state.class , "Check start state is a string class in #{csv_file}")
    end # end each file
	end # end test




  # Create Dot Graph
  # 
  # Creates dot graph (GraphViz) and then checks that it can be written out.
  # This helps to ensure its a kosher graphviz object.
  #
  def test_create_dot_graph_csv
    @valid_csv_files.each do |csv_file|
      puts csv_file
      smc = StateModelCreator.new
      sm = smc.load_table(csv_file)
      
		  # Create the Graphiz graph object, see if it fails...
		  sm_graph = sm.create_dot_graph	

		  # Check that the graph produced is at least of the correct class
		  assert_equal(Graph.new.class, sm_graph.class ,"Check graph is instance of graph class")	
		
		  # Output DOT version of the graph, see if it fails...
		  file_name=csv_file.sub(/\.csv$/ , '_csv')
		  sm_graph.output("#{file_name}.dot")
		   
		  assert(File.exist?("#{file_name}.dot"),"Check the graph file: #{file_name}.dot was written out.")
		  
	  end # end valid csvs
	end # end test method 

  # Create Dot Graph
  # 
  # Creates dot graph (GraphViz) and then checks that it can be written out.
  # This helps to ensure its a kosher graphviz object.
  #
  def build_dsl_10
    smc =StateModelCreator.new
     smc.define_action :action1 do 
       @action1_done=true
     end # end action
     smc.define_action :action2
     smc.define_guard_on :action2 do
       if @action1_done
         guard=true
       else
         guard=false
       end # end if
       guard
     end # end guard
     smc.define_action :action3
     smc.define_action :action4
     smc.attach_transition(:STATEA,:action1,:STATEB)
     smc.attach_transition(:STATEB,:action2,:STATEC)
     smc.attach_transition(:STATEC,:action3,:STATED)
     smc.attach_transition(:STATEC,:action4,:STATEE)
     sm = smc.state_machine
     return sm
  end # end def
  
  def test_create_dot_graph_dsl
    sm = build_dsl_10
	  sm_graph = sm.create_dot_graph	
	  assert(sm_graph.to_s.scan(/Guard\//).length==1 , "Check That a Guard has been added")
	  sm_graph.output("test10_dsl.dot")
	  assert(File.exist?("test10_dsl.dot"),"Check the graph file: test10_dsl.dot was written out.")
	
 	end # end method
   	   


  # Random Walk
  #
	def test_random_walk_simple
		smc = StateModelCreator.new
		sm = smc.load_table(@path + TEST1_CSV)
		
		# Check standard length walk
		the_walk = sm.random_walk("STATEA")
		assert_equal(Walk.new.class ,               the_walk.class ,              "Check random walk returns Walk instance" )
		assert_equal(StateMachine::MAX_STEPS , the_walk.transitions.length , "Check Walks to the maximum in a loop.")
		
		# Check limited length walk
		the_walk = sm.random_walk("STATEA",5)
		assert_equal(5 , the_walk.transitions.length , "Check Walks to the given length in a loop.")

    # Check that exception raised if walk length is daft (<=2)
    assert_raises RuntimeError do
      the_walk = sm.random_walk("STATEA" , 2)
    end # Assert Raises
		
	end # end 
	 
	  
	# Random Walk
	# Sanity check % stats returned
	# Also do a specific check...
	#
	def test_random_walk_muliple
	  @valid_csv_files.each do |csv_file|
  		smc = StateModelCreator.new(true)	  
  		sm = smc.load_table(csv_file)
  		
	    the_walk = sm.random_walk("STATEA")
		
	    # Puts it, hope there is no exceptions
	    puts the_walk
	    # Generic checks on coverage stats
	    check_coverage_stats(the_walk)
    end # end loop over csvs
	
	  # Specific checks for coverage on this model
	  smc = StateModelCreator.new	  
	  sm = smc.load_table(TEST10_CSV)
	  
		a_walk = sm.random_walk("STATEA")
    assert_equal(80 , a_walk.state_coverage , "Check State coverage is 80% for TEST10_CSV")
		assert_equal(75 , a_walk.transition_coverage , "Check Transition coverage is 75% for TEST10_CSV")
	
	end # end test
  
  # Walk-State and transition coverage
  #
  # Sanity check that the values are within realistic constraints
  #
  def check_coverage_stats(the_walk)
		# Check coverage stats are sane.
		assert(the_walk.state_coverage <= 100 , "Check State coverage is <=100")
		assert(the_walk.state_coverage > 0 , "Check State coverage is >0")
		
		assert(the_walk.transition_coverage <= 100 , "Check transition coverage is <=100")
		assert(the_walk.transition_coverage > 0 , "Check transition coverage is >0")		    
  end # end coverage stats

  # Random Walk
  #
  # Check that the Random Walker follows a simple straight line graph ok.
  # Path is detirministic as there is only one option for progression on each node.
  #
  def test_random_walk_many_straight_steps
    smc = StateModelCreator.new
		sm = smc.load_table(TEST5_CSV)
		
		the_walk = sm.random_walk("STATEA")
    puts "test_random_walk_many_straight_steps"
    puts the_walk
    # Check that the transitions are found (when only 1 choice) and ordered correctly
	  trans = the_walk.transitions
    assert(trans[0].start_state=="STATEA" , "State A is 1st start state")
    assert(trans[0].end_state=="STATEB" , "State B is 1st end state")
    
    assert(trans[1].start_state=="STATEB" , "State B is 2nd start state")
    assert(trans[1].end_state=="STATEC" , "State C is 2nd end state")
    
    assert(trans[2].start_state=="STATEC" , "State C is 3rd start state")
    assert(trans[2].end_state=="STATED" , "State D is 3rd end state")

    assert(trans[3].start_state=="STATED" , "State D is 4th start state")
    assert(trans[3].end_state=="STATEE" , "State E is 4th end state")

    assert(trans[4].start_state=="STATEE" , "State E is 5th start state")
    assert(trans[4].end_state=="STATEF" , "State F is 5th end state")
        
    assert(trans[5].start_state=="STATEF" , "State F is 6th start state")
    assert(trans[5].end_state=="STATEG" , "State G is 6th end state")
    
    assert(trans[6].start_state=="STATEG" , "State G is 7th start state")
    assert(trans[6].end_state=="STATEH" , "State H is 7th end state")

  end # end test


  # General: Death tests
  # Ensure the system exits with Runtime Errors when blatantly bad data is provided.
  #
	def test_random_walk_file_issues
		
		# CSV file with just a header
		assert_raises RuntimeError do
			smc = StateModelCreator.new
			smc.load_table(@path + TEST2_1LINE_CSV)
		end # Assert Raises	
		
		# A CSV File with nothing in it.
		assert_raises RuntimeError do
			smc = StateModelCreator.new
			smc.load_table(@path + TEST3_0LINE_CSV)
		end # Assert Raises	
	end # end test
	
	
	# Drive Using
	# drive_using can directly control a sut driver object and follow a given walk.
	# The 'walk' is passed the 'driver', the walk then executes any transitions contained in the walk.
	# Assertions are placed in the driver and therefore executed as part of this process.
	def test_model_driver_simple_csv
	  smc = StateModelCreator.new # Create model
	  system_model = smc.load_table(@path + TEST10_CSV)
	  
		model_walk = system_model.random_walk("STATEA")  # Create walk starting at ...
		
		sut_driver = EgTestDriver.new     # Instantiate your target system's test driver
		model_walk.drive_using sut_driver # Apply the 'Walk' to your driver code.
		# Ensure correct transitions were followed, in correct order
	  assert_equal(sut_driver.transitions_travelled , model_walk.transitions)
	  
	  # Compile list of states that should get tested in the SUT
	  models_states=Array.new
	  model_walk.transitions.each do |a_transition|
	    if models_states.length==0
	      models_states.push a_transition.start_state
	    end # if first state
	    models_states.push a_transition.end_state
    end # end do trans
    
	  assert_equal(sut_driver.states_tested , models_states)
	  
  end # end driver tests
	
	def test_model_driver_simple_dsl
	  
	  system_model = build_dsl_10  # Create model
	  
		model_walk = system_model.random_walk(:STATEA)  # Create walk starting at ...
		
		sut_driver = EgTestDriver.new(true)     # Instantiate your target system's test driver
		model_walk.drive_using sut_driver # Apply the 'Walk' to your driver code.
		# Ensure correct transitions were followed, in correct order
	  assert_equal(sut_driver.transitions_travelled , model_walk.transitions)
	  
	  # Compile list of states that should get tested in the SUT
	  models_states=Array.new
	  model_walk.transitions.each do |a_transition|
	    if models_states.length==0
	      models_states.push a_transition.start_state
	    end # if first state
	    models_states.push a_transition.end_state
    end # end do trans
    
	  assert_equal(sut_driver.states_tested , models_states)
	  
  end # end driver tests
	
	
	
	
	# Drive Using
	# Just check a runtime error is raised when a string is passsed in
	# instead of a valid driver. A common error.
	# To allow any old code /driver to be used though - means i 
	# can not be very specific about what i allow.
	def test_model_driver_messy
	  smc = StateModelCreator.new # Create model
	  system_model = smc.load_table(TEST10_CSV)
	  
		model_walk = system_model.random_walk("STATEA")  # Create walk starting at ...
		
		sut_driver = String.new             # Instantiate bogus test driver
		assert_raises RuntimeError do
		  model_walk.drive_using sut_driver # Ensure exception occurs when not real driver
	  end # end assert raises
	  
  end # end messy driver tests
	
	# Unit Tests for a method that examines adjacency matrix and returns the transitions 
	# 
	def test_extract_valid_transitions

	  @valid_csv_files.each_index do |csv_file_index|
  	  smc = StateModelCreator.new # Create model
  	  system_model = smc.load_table(@valid_csv_files[csv_file_index])
  	  
		  # Test that correct number of transitions were extracted
		  assert_equal(@valid_csv_files_transitions[csv_file_index], system_model.extract_valid_transitions.length, "Check for correct number of transitions: #{@valid_csv_files[csv_file_index]}")
		end # end csv files
    
    # Check specific example has correct values set
    
    # Manually create 2 transitions, These match those in TEST1_CSV
    smc = StateModelCreator.new # Create model
    system_model = smc.load_table(TEST1_CSV)
    
    correct_transition1=TransitionHolder.new("STATEA","action1","STATEB")
    correct_transition2=TransitionHolder.new("STATEB","action2","STATEA")
    # Obtain our extracted transitions
    sut_trans = system_model.extract_valid_transitions
	  sut_transitionX=sut_trans[0]
	  
	  # Compare X transitions with each manually created one.
	  # We can not detirmine what order they will be extracted.
	  # Therefore we have to check that one pair matches and the other does not.
	  pairX1,pairX2 = false , false
	  if sut_transitionX == correct_transition1 
	    pairX1=true
    end # end if
	  if sut_transitionX == correct_transition2 
	    pairX2=true
    end # end if
    puts "Pair checks:#{pairX1},#{pairX2}"
    assert(pairX1||pairX2, "A extracted transition should match -one- of these manually created ones")
    assert(pairX1!=pairX2, "Check that extracted transition does not match both manual ones (this is a bit redundant).")
    
  end # end test mthod
	
	
	
  # DSL Stuff
  #
  def test_state_simple_transition_define

     myfsmc = StateModelCreator.new
     myfsmc.define_action :action1 do
         puts "stuff"
       end # end add action

     # Create a transition
     myfsmc.attach_transition(:STATEA ,:action1 ,:STATEB)
     # Check states were added
     assert(myfsmc.states.include?(:STATEA) , "Check STATEA added")
     assert(myfsmc.states.include?(:STATEB) , "Check STATEB added")
   end # end test  


    # If an action isn't there should throw an exception
    #
    def test_state_simple_transition_missing

      myfsmc = StateModelCreator.new
      assert_raises RuntimeError do
        returned_obj = myfsmc.attach_transition(:state1 , :action3 , :state2)
      end # end assert

    end # end state test

    def test_action_simple_action_define
       myfsmc = StateModelCreator.new
       myfsmc.define_action :action1 do
           puts "stuff"
         end # end add action

       assert_equal(:action1 , myfsmc.actions[0], "Check name of loose action")

       myfsmc.attach_transition(:STATEA, :action1 , :STATEB)
       
       
       
       # Check method there by just calling it...
       sm = myfsmc.state_machine
       sm.state=:STATEA
       assert_equal(:STATEB , sm.action1 , "Check new state is STATEB, using return from StateMachine#action_name")
       assert_equal(:STATEB , sm.state , "Check new state is STATEB, using StateMachine#state")
       # Hopefully that did not throw an exception.

       # Lets add another
       myfsmc.define_action :action2
       myfsmc.attach_transition(:STATEA, :action2 , :STATEB)
       sm = myfsmc.state_machine
       sm.state=:STATEA
       
       # Check they have both been added (low rent test)
       assert(myfsmc.actions.length==2, "Check 2 entries added to actions list")
       
       the_state_machine = myfsmc.state_machine
       the_state_machine.action2
       

     end # end test

   	def test_random_walk_simple_dsl
   		smc = StateModelCreator.new
   		smc.define_action :action1
      smc.define_action :action2
   		smc.attach_transition(:STATEA,:action1,:STATEB)
   		smc.attach_transition(:STATEB,:action2,:STATEA)
   		sm = smc.state_machine
      
      assert_equal(2 , sm.states_store.length , "Check for 2 states")

   		# Check standard length walk
   		the_walk = sm.random_walk(:STATEA)
   		assert_equal(Walk.new.class ,               the_walk.class ,              "Check random walk returns Walk instance" )
   		assert_equal(StateMachine::MAX_STEPS , the_walk.transitions.length , "Check Walks to the maximum in a loop.")

   		# Check limited length walk
   		the_walk = sm.random_walk(:STATEA,5)
   		assert_equal(5 , the_walk.transitions.length , "Check Walks to the given length in a loop.")

       # Check that exception raised if walk length is daft (<=2)
       assert_raises RuntimeError do
         the_walk = sm.random_walk(:STATEA , 2)
       end # Assert Raises

   	end # end

   	def test_steps_simple_dsl
   		smc = StateModelCreator.new
   		smc.define_action :action1
      smc.define_action :action2
   		smc.attach_transition(:STATEA,:action1,:STATEB)
   		smc.attach_transition(:STATEB,:action2,:STATEA)
   		system_model = smc.state_machine

      system_model.state = :STATEA
      new_state = system_model.action1
      assert(new_state==:STATEB, "Check action1 transitioned to STATEB - returned value")
      assert(system_model.state==:STATEB, "Check action1 transitioned to STATEB - state value")
      

    end # end def

	def teardown
	end # end teardown/clearup
	
end # end class

