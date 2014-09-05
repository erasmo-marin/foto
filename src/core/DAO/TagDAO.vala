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

public class TagDAO {

    private static DbManager db;
    public signal void tag_inserted(Tag tag);
    public signal void tag_deleted(Tag tag);
    private static TagCollection tag_collection;

    private static TagDAO self;

    private TagDAO() {

        if (db == null)
            db = new DbManager();
            debug("DbManager created\n");
        if (tag_collection == null)
            tag_collection = new TagCollection();
            debug("TagCollection created\n");

    }

    public static TagDAO get_instance () {
        if (self == null) {
            self = new TagDAO();
        }
        return self;
    }

    public TagCollection get_all () {

        debug("TagDAO.get_all");
        Statement stmt = db.select_all(DbManager.Table.TAG);
        TagCollection collection = new TagCollection();
        int rc = -1;
        int cols = stmt.column_count();

        int id = -1;
        string tag = null;

        do {

            debug("TagDAO.get_all do while");

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
                                tag = stmt.column_text(col);
                                break;
                            default:
                                break;
                        }
                    }
                    debug("TagDAO.get_all case row");
                    debug("TagDAO.get_all creating pic: %d, %s",id, tag);
                    Tag _tag = new Tag.with_values(id, tag);
                    debug("TagDAO.get_all collection add new");
                    collection.add(_tag);
                    break;

                default:
                    critical ("Error parsing database\n");
                    break;
                }
            } while (rc == Sqlite.ROW);
        return collection;
    }

    public bool insert(Tag tag) {

        debug("TagDAO.insert Request\n");

	    DbManager.Data[] values = { new DbManager.Data.from_int(tag.id),
                                    new DbManager.Data.from_string(tag.tag),
                                  };
        debug("TagDAO.insert values generated\n");
	    
        if (db.insert(DbManager.Table.TAG, values)) {
            tag_inserted(tag);
            return true;
        }
        return false;
    }

    public bool remove() {

        return false;
    }
}