require 'mongo'
module Mongify
  module Database
    #
    # No Sql Connection configuration
    # 
    # Basic format should look something like this:
    # 
    #   no_sql_connection do
    #     adapter   "mongodb"
    #     host      "localhost"
    #     database  "my_database"
    #   end
    # 
    # Possible attributes:
    #   adapter
    #   host
    #   database
    #   username
    #   password
    #   port
    #
    class NoSqlConnection < Mongify::Database::BaseConnection
      include Mongo
      
      #Required fields for a no sql connection
      REQUIRED_FIELDS = %w{host database}  
      
      def initialize(options=nil)
        super options
        adapter 'mongodb' if adapter.nil? || adapter == 'mongo'
      end
      
      # Sets and/or returns a adapter
      # It takes care of renaming adapter('mongo') to 'mongodb'
      def adapter(name=nil)
        name = 'mongodb' if name && name.to_s.downcase == 'mongo'
        super(name)
      end
      
      # Returns a connection string that can be used to build a Mongo Connection
      # (Currently this isn't used due to some issue early on in development)
      def connection_string
        "#{@adapter}://#{@host}#{":#{@port}" if @port}"
      end
      
      # Returns true or false depending if the given attributes are present and valid to make up a 
      # connection to a mongo server
      def valid?
        super && @database.present?
      end
      
      # Sets up a connection to the database
      def setup_connection_adapter
        connection = Connection.new(host, port)
        connection.add_auth(database, username, password) if username && password
        connection
      end
      
      # Returns a mongo connection
      def connection
        @connection ||= setup_connection_adapter
      end
      
      # Returns true or false depending if we have a connection to a mongo server
      def has_connection?
        connection.connected?
      end
      
      # Returns the database from the connection
      def db
        @db ||= connection[database]
      end
      
      # Returns a hash of all the rows from the database of a given collection
      def select_rows(collection)
        db[collection].find
      end
      
      # Inserts into the collection a given row
      def insert_into(colleciton_name, row)
        db[colleciton_name].insert(row, :safe => true)
      end
      
      # Updates a collection item with a given ID with the given attributes
      def update(colleciton_name, id, attributes)
        db[colleciton_name].update({"_id" => id}, attributes)
      end
      
      # Finds one item from a collection with the given query
      def find_one(collection_name, query)
        db[collection_name].find_one(query)
      end
      
      # Returns a row of a item from a given collection with a given pre_mongified_id
      def get_id_using_pre_mongified_id(colleciton_name, pre_mongified_id)
        db[colleciton_name].find_one('pre_mongified_id' => pre_mongified_id).try(:[], '_id')
      end
      
      # Removes pre_mongified_id from all records in a given collection
      def remove_pre_mongified_ids(collection_name)
        db[collection_name].update({}, { '$unset' => { 'pre_mongified_id' => 1} }, :multi => true)
      end
      
    end
  end
end