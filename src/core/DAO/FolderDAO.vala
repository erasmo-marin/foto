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

using Sqlite;

public class FolderDAO {

    private static DbManager db;
    private FolderDAO self;

    public signal void folder_inserted(Folder folder);

    private FolderDAO () {
        if (db == null)
            db = new DbManager();
            debug("DbManager created\n");
    }

    public FolderDAO get_instance() {
        if (self == null) {
            self = new FolderDAO();
        }
        return self;
    }

    public Gee.ArrayList<Folder> get_all() {
        debug("PictureDAO.get_all");
        Statement stmt = db.select_all(DbManager.Table.FOLDER);
        return build_collection_from_statement(stmt);
    }

    public bool insert(Folder folder) {
        debug("AlbumDAO.insert Request\n");
        int import = 0;
        if (folder.is_import_folder)
            import = 1;

	    DbManager.Data[] values = { new DbManager.Data.from_int(folder.id),
                                    new DbManager.Data.from_string(folder.folder_path),
                                    new DbManager.Data.from_int(import),
                                   };
        debug("FolderDAO.insert values generated\n");

	    
        if (db.insert(DbManager.Table.FOLDER, values)) {
            folder_inserted(folder);
            return true;
        }
        return false;   
    }

    private Gee.ArrayList<Folder> build_collection_from_statement(Statement stmt) {

        debug("FolderDAO.build_colletion_from_statement");
        var collection = new Gee.ArrayList<Folder>();

        int rc = -1;
        int cols = stmt.column_count();

        int id = -1;
        string folder_path = null;
        bool is_import_folder = false;

        do {
            rc = stmt.step();

            switch (rc) {

                case Sqlite.DONE:
                    break;

                case Sqlite.ROW:
                    for (int col = 0; col < cols; col++) {
                        
                        switch(col){
                            case 0:
                                id = stmt.column_int(col);
                                break;
                            case 1:
                                folder_path = stmt.column_text(col);
                                break;
                            case 2:
                                int import = stmt.column_int(col);
                                if(import == 1)
                                    is_import_folder = true;
                                break;
                            default:
                                break;
                        }
                    }
                    Folder folder = new Folder.with_values(id, folder_path, is_import_folder);
                    collection.add(folder);
                    break;

                default:
                    critical ("Error parsing database\n");
                    break;
                }
            } while (rc == Sqlite.ROW);
        return collection;
    }

}