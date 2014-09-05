// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013-2014 Foto Developers (http://launchpad.net/foto)
 *
 * This software is licensed under the GNU General Public License
 * (version 3 or later). See the COPYING file in this distribution.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this software; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 * Authored by: Erasmo Marín <erasmo.marin@gmail.com>
 */

using GLib;
using Gee;
using Sqlite;

public class DbManager {

    private static Database db;
    private static const string version = "1.0";
    private static string database_dir = "/foto-" + version + ".db";
    private static string old_database_dir = "/Foto1.0.db";

    private static string create_table_album = "CREATE TABLE "+ Table.ALBUM.to_string() +
                                                 " (id INTEGER PRIMARY KEY, album_name TEXT UNIQUE NOT NULL,
                                                    creation_date INTEGER NOT NULL, comment TEXT,
                                                    rating INTEGER DEFAULT 0, color INTEGER NOT NULL);";

    private static string create_table_picture = "CREATE TABLE "+ Table.PICTURE.to_string()+
                                                   "(id INTEGER PRIMARY KEY, file_path TEXT UNIQUE NOT NULL, 
                                                    import_date INTEGER, tags TEXT, thumbnail_md5 TEXT, rating INTEGER DEFAULT 0, 
                                                    comment TEXT, album_id INTEGER);";

    private static string create_table_tag = "CREATE TABLE "+ Table.TAG.to_string() +
                                               " (id INTEGER PRIMARY KEY, tag TEXT UNIQUE NOT NULL);";

    private static string create_table_folder = "CREATE TABLE "+ Table.FOLDER.to_string() +
                                               " (id INTEGER PRIMARY KEY, folder_path TEXT UNIQUE NOT NULL, is_import_folder INTEGER);";

    //constructor
    public DbManager(){

        if(db == null) {
            string DATA_DIR = Environment.get_user_data_dir();
            string db_location_foto = DATA_DIR + "/foto";
            Granite.Services.Paths.initialize("foto", Build.PKGDATADIR);
            database_dir = db_location_foto + database_dir;

            if (!FileUtils.test (database_dir, FileTest.IS_REGULAR)) {
                debug("Database %s does not exist, creating new database\n", database_dir);
                debug("DbManager.create_db()");
                create_db();
            } else {
                Database.open_v2 (database_dir, out db);
            }
        }
    }

    //for debug only
    public static int callback (int n_columns, string[] values,
                                  string[] column_names){

        for (int i = 0; i < n_columns; i++) {
            debug ("%s = %s\n", column_names[i], values[i]);
        }
        debug ("\n");
        return 0;
    }

    //exec any query without return any data
    public bool exec(string query) {
        db.exec (query, (Sqlite.Callback) callback, null);
        return true;
    }

    //exec any query returning a Statement
    public Statement? exec_query(string query){
        Statement stmt;
        int rc;
        if ((rc = db.prepare_v2 (query, -1, out stmt, null)) == 1) {
            warning ("SQL error: %d, %s\n", rc, db.errmsg ());
            return null;
         }

        return stmt;        
    }

    public Statement? select_all(Table table) {

        string query = "SELECT * FROM " + table.to_string() + ";";
        return exec_query(query);
    }

    public Statement? select_where(Table table, string condition) {

        string query = "SELECT * FROM " + table.to_string() + " WHERE " + condition + ";";
        return exec_query(query);

    }

    //insert values in table. 
    public bool insert(Table table, Data[] values) {
        debug("DbManager.insert\n");

        string query = "INSERT INTO " + table.to_string() + " VALUES (";

        string[] values_str = {};

        foreach (Data val in values) {

            string v;
            if (val.data_type == Data.Type.STRING) {
                v = "'" + val.get_data() + "'";
            } else if (val.data_type == Data.Type.NULL) {
                v = "null";
            } else {
                v = val.get_data();
            }
            values_str+=v;
        }
        query = query + string.joinv(",",values_str) + ");";
        debug("*QUERY INSERT: " +query + "\n");
        return exec(query);
    }

    //TODO
    public bool edit_where() {
        return false;
    }


    public bool delete_where(string table, string condition) {
        string query = "DELETE FROM " + table + " WHERE" +  condition + ";";
        return exec(query);
    }


    //create db
    private void create_db(){

        debug("create database");
        int rc = Database.open_v2 (database_dir, out db);
        if (rc != Sqlite.OK)
            critical("Couldn't open database: %d, %s", rc, db.errmsg ());

        debug("create table album");
        rc = db.exec (create_table_album, (Sqlite.Callback) callback, null);
        if (rc != Sqlite.OK)
            error("SQL error in '%s': %d, %s\n", create_table_album, rc, db.errmsg ());

        debug("create table picture");
        rc = db.exec (create_table_picture, (Sqlite.Callback) callback, null);
        if (rc != Sqlite.OK)
            error("SQL error in '%s': %d, %s\n", create_table_picture, rc, db.errmsg ());

        debug("create table tag");
        rc = db.exec (create_table_tag, (Sqlite.Callback) callback, null);
        if (rc != Sqlite.OK)
            error("SQL error in '%s': %d, %s\n", create_table_tag, rc, db.errmsg ());

        debug("create table folder");
        rc = db.exec (create_table_folder, (Sqlite.Callback) callback, null);
        if (rc != Sqlite.OK)
            error("SQL error in '%s': %d, %s\n", create_table_folder, rc, db.errmsg ());


    }

    //TODO:What to do if model changes (import old data to the new model)
    private void on_import() {
        debug("Not implemented");
    }

    public enum Table {

        PICTURE,
        ALBUM,
        TAG,
        FOLDER;

        //this allow us to change table names no affecting DAO classes
        public string to_string() {

            switch(this){
                case PICTURE:
                    return "Picture";
                case ALBUM:
                    return "Album";
                case TAG:
                    return "Tag";
                case FOLDER:
                    return "Folder";
                default:
                    assert_not_reached();
            }
        }
    }

    //A data class that can be used as string or int at same time
    public class Data {

        public enum Type {
            STRING,
            INT,
            NULL;
        }

        private string? str_data;
        private int? num_data;
        public Type data_type; 

        public Data.from_string (string? data) {
            debug("Data.from_string: ");
            if(data == null)
                data_type = Type.NULL;
            else
                data_type = Type.STRING;
            str_data = data;
            debug(get_data() + "\n");
        }

        public Data.from_int (int? data) {
            debug("Data.from_int\n");
            if(data == null)
                data_type = Type.NULL;
            else
                data_type = Type.INT;
            num_data = data;
        }

        public string? get_data() {
            if (data_type == Type.INT) {
                return num_data.to_string();
            } else if(data_type == Type.STRING) {
                return str_data;
            } else {
                return "null";
            }
        }
    }














}