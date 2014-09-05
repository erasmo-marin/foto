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

public class PictureDAO {

    private static DbManager db;
    public signal void picture_inserted(Picture picture);
    public signal void picture_edited(Picture picture);
    public signal void picture_deleted(Picture picture);
    private static PictureCollection picture_collection;

    private static PictureDAO self;

    private PictureDAO() {

        if (db == null)
            db = new DbManager();
            debug("DbManager created\n");
        if (picture_collection == null)
            picture_collection = new PictureCollection();
            debug("PictureCollection created\n");

    }

    public static PictureDAO get_instance () {
        if (self == null) {
            self = new PictureDAO();
        }
        return self;
    }

    public PictureCollection get_all () {

        debug("PictureDAO.get_all");
        Statement stmt = db.select_all(DbManager.Table.PICTURE);
        return build_collection_from_statement(stmt);
    }

    public bool insert(Picture pic) {

        debug("PictureDAO.insert Request\n");
        string tags = null;
        if(pic.tags != null && pic.tags.length>0) {
            tags = string.joinv(",",pic.tags);
        }

	    DbManager.Data[] values = { new DbManager.Data.from_int(pic.id),
                                    new DbManager.Data.from_string(pic.file_path),
                                    new DbManager.Data.from_int(pic.import_date),
                                    new DbManager.Data.from_string(tags),
                                    new DbManager.Data.from_string(pic.thumbnail_md5),
                                    new DbManager.Data.from_int((int)pic.rating),
                                    new DbManager.Data.from_string(pic.comment),
                                    new DbManager.Data.from_int(pic.album_id)
                                   };
        var tagdao = TagDAO.get_instance();
        if (db.insert(DbManager.Table.PICTURE, values)) {
            picture_inserted(pic);
            foreach (string tag in pic.tags) {
                tagdao.insert(new Tag.with_values(null, tag));
            }

            return true;
        }
        return false;
    }

    public PictureCollection get_last_import() {
        debug("PictureDAO.get_last_import Request\n");
        string query = "SELECT * FROM picture where import_date = (SELECT MAX(import_date) from picture);";
        Statement stmt = db.exec_query(query);
        return build_collection_from_statement(stmt);
    }

    public bool edit() {

        return false;
    }

    public bool remove() {

        return false;
    }


    public PictureCollection search_by_tag(Tag tag) {
        debug("PictureDAO.search_by_tag Request\n");
        Statement stmt = db.select_where(DbManager.Table.PICTURE, "picture.tags LIKE '%" + tag.tag + "%'");
        return build_collection_from_statement(stmt);
    }

    public PictureCollection get_for_album(Album album) {
        Statement stmt = db.select_where(DbManager.Table.PICTURE, "album_id =" + album.id.to_string());
        return build_collection_from_statement(stmt);
    }

    public bool set_album_to_picture(Picture picture, Album album) {
        string query = "UPDATE "+ DbManager.Table.PICTURE.to_string() +" SET album_id = "+ album.id.to_string() +" WHERE id = "+ picture.id.to_string() +";";
        return db.exec(query);
    }

    public bool set_album_to_collection(PictureCollection collection, Album album) {
        string query = "UPDATE "+ DbManager.Table.PICTURE.to_string() +" SET album_id = "+ album.id.to_string() +" WHERE id =" + collection.get(0).id.to_string();

        for(int i=1; i<collection.size; i++) {
            query += " OR id = " + collection.get(i).id.to_string();
        }

        query+=";";
        return db.exec(query);
    }

    public int count() {
        string query = "SELECT COUNT(id) FROM picture";
        Statement stmt = db.exec_query(query);
        int count = -1;
        int rc = stmt.step();

        switch (rc) {
                case Sqlite.ROW:
                    count = stmt.column_int(0);
                    break;
                default:
                    break;
        }
        return count;
    }


    private PictureCollection build_collection_from_statement(Statement stmt) {

        debug("PictureDAO.build_colletion_from_statement");
        PictureCollection collection = new PictureCollection();

        int rc = -1;
        int cols = stmt.column_count();

        int id = -1;
        string file_path = null;
        int import_date = -1;
        string tags_str = null;
        string[] tags = null;
        string thumbnail_md5 = null;
        uint rating = 0;
        string comment = null;
        int album_id = -1;

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
                                file_path = stmt.column_text(col);
                                break;
                            case 2:
                                import_date = stmt.column_int(col);
                                break;
                            case 3:
                                tags_str = stmt.column_text(col);
                                break;
                            case 4:
                                thumbnail_md5 = stmt.column_text(col);
                                break;
                            case 5:
                                rating = stmt.column_int(col);
                                break;
                            case 6:
                                comment = stmt.column_text(col);
                                break;
                            case 7:
                                album_id = stmt.column_int(col);
                                break;
                            default:
                                break;
                        }
                    }
                    if(tags_str != null)
                        tags = tags_str.split_set (",");
                    debug("PictureDAO.get_collection_from_statement creating pic: %d, %s, %d, %s, %s, %d, %s, %d",id, file_path, import_date, "{" + tags_str + "}", thumbnail_md5, (int)rating, comment, album_id);
                    Picture pic = new Picture.with_values(id, file_path, import_date, tags, thumbnail_md5, rating, comment, album_id);
                    collection.add(pic);
                    break;

                default:
                    critical ("Error parsing database\n");
                    break;
                }
            } while (rc == Sqlite.ROW);
        return collection;
    }
}