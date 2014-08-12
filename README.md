#VHS

created by J.J.Idt[https://github.com/jjidt]

lightweight ruby CRUDL module for use with postgresql

##To use

###from command line run

gem install pg

###require pg gem in your ruby file

require 'pg'

###set your database constant in your ruby file

DB = PG.connect(:dbname => 'your_database')

###VHS will dynamically create classes based on your table names in the database

if table is 'things'

class will be accessible at Vhs::Thing

###Create a new item in the 'things' table containing 'name' column in database

thing_id = Vhs::Thing.new('name' => 'thing_name').create

**create returns the corresponding id from the database
***here it is stored in the variable thing_id

###Read an array of items from the database by passing in any column and value

Vhs::Thing.read('name' => 'thing_name')

###Update an item in the database by passing two parameters .update(new_values, identifier_values)

Vhs::Thing.update({'name' => 'new_name'}, {'name' => 'thing_name'})

###Delete an item from the database by passing in an identifier

Vhs::Thing.delete('name' = 'new_name')

###List all items in a table

Vhs::Thing.list

###Join items from 2 tables by passing in the right_table, join_table, and desired retrieval value

Vhs::Book.join_by_name('right_table' => 'authors', 'join_table' => 'authors_books', 'name' => 'Vonnegut')

this will return an array of book objects

MIT License
