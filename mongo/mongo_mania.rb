//Mongo Driver 2.1.x 

require 'mongo'
mc_with_debug = Mongo::Client.new('mongodb://127.0.0.1:27017/some')
stack_withdebug = mc[:stack]
// Mongo::Logger.logger.level = Logger::DEBUG

mc = Mongo::Client.new('mongodb://127.0.0.1:27017/some', :monitoring => false)
stack = mc[:stack]

stack.find().each do |doc|
   puts doc
end
 
puts stack.find(:name => "pony").to_json
[{"_id":{"$oid":"563930e3b70dd72dd693e054"},"name":"pony"},{"_id":{"$oid":"563930f2b70dd72dd693e055"},"name":"pony","test":false},{"_id":{"$oid":"5639310cb70dd72dd693e056"},"name":"pony","test":true}]


stack_withdebug.find().each { |doc| puts doc.to_json }
D, [2015-11-04T09:41:27.592567 #5631] DEBUG -- : MONGODB | 127.0.0.1:27017 | some.find | STARTED | {"find"=>"stack", "filter"=>{}}
D, [2015-11-04T09:41:27.593255 #5631] DEBUG -- : MONGODB | 127.0.0.1:27017 | some.find | SUCCEEDED | 0.000537158s
{"_id":{"$oid":"56392a607a77f0b1c61407a6"},"foo":"abc","test":true,"someNumber":4142}
{"_id":{"$oid":"563930deb70dd72dd693e053"},"name":"big pony"}
{"_id":{"$oid":"563930e3b70dd72dd693e054"},"name":"pony"}
{"_id":{"$oid":"563930f2b70dd72dd693e055"},"name":"pony","test":false}
{"_id":{"$oid":"5639310cb70dd72dd693e056"},"name":"pony","test":true}
=> #<Enumerator: ...>

stack_withdebug.find().each { |doc| puts doc }
D, [2015-11-04T09:42:09.385705 #5631] DEBUG -- : MONGODB | 127.0.0.1:27017 | some.find | STARTED | {"find"=>"stack", "filter"=>{}}
D, [2015-11-04T09:42:09.386524 #5631] DEBUG -- : MONGODB | 127.0.0.1:27017 | some.find | SUCCEEDED | 0.000667637s
{"_id"=>BSON::ObjectId('56392a607a77f0b1c61407a6'), "foo"=>"abc", "test"=>true, "someNumber"=>4142}
{"_id"=>BSON::ObjectId('563930deb70dd72dd693e053'), "name"=>"big pony"}
{"_id"=>BSON::ObjectId('563930e3b70dd72dd693e054'), "name"=>"pony"}
{"_id"=>BSON::ObjectId('563930f2b70dd72dd693e055'), "name"=>"pony", "test"=>false}
{"_id"=>BSON::ObjectId('5639310cb70dd72dd693e056'), "name"=>"pony", "test"=>true}
=> #<Enumerator: ...>


// Mongo Shell
MongoDB shell version: 2.6.10
connecting to: test
> use some
switched to db some
> db.stack.insert({"name" : "big pony"})
WriteResult({ "nInserted" : 1 })
> db.stack.insert({"name" : "pony"})
WriteResult({ "nInserted" : 1 })
> db.stack.insert({"name" : "pony", test:false})
WriteResult({ "nInserted" : 1 })
> db.stack.find()
{ "_id" : ObjectId("56392a607a77f0b1c61407a6"), "foo" : "abc", "test" : true, "someNumber" : 4142 }
{ "_id" : ObjectId("563930deb70dd72dd693e053"), "name" : "big pony" }
{ "_id" : ObjectId("563930e3b70dd72dd693e054"), "name" : "pony" }
{ "_id" : ObjectId("563930f2b70dd72dd693e055"), "name" : "pony", "test" : false }
{ "_id" : ObjectId("5639310cb70dd72dd693e056"), "name" : "pony", "test" : true }
> 
