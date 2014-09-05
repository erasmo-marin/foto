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

public class AlbumDAO {

    private static DbManager db;

    public signal void album_inserted (Album album);
    public signal void album_edited (Album album);
    public signal void album_deleted (Album album);

    private Gee.ArrayList<Album> AlbumList;
    private static AlbumDAO self;

    private AlbumDAO() {

        if (db == null)
            db = new DbManager();
        if (AlbumList == null)
            AlbumList = new Gee.ArrayList<Album>();
    }

    public static AlbumDAO get_instance () {
        if (self == null) {
            self = new AlbumDAO();
        }
        return self;
    }


    public AlbumCollection get_all () {

        debug("AlbumDAO.get_all");
        Statement stmt = db.select_all(DbManager.Table.ALBUM);
        AlbumCollection collection = new AlbumCollection();
        int rc = -1;
        int cols = stmt.column_count();

        int id = -1;
        string album_name = null;
        int creation_date = -1;
        string comment = null;
        int rating = 0;
        int color = 0;

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
                                album_name = stmt.column_text(col);
                                break;
                            case 2:
                                creation_date = stmt.column_int(col);
                                break;
                            case 3:
                                comment = stmt.column_text(col);
                                break;
                            case 4:
                                rating = stmt.column_int(col);
                                break;
                            case 5:
                                color = stmt.column_int(col);
                                break;
                            default:
                                break;
                        }
                    }
                    debug("AlbumDAO.get_all case row");
                    debug("AlbumDAO.get_all creating album: %d, %s, %d, %s, %d, %d",id, album_name, creation_date, comment, rating, color);
                    Album album = new Album.with_values(id, album_name, creation_date, comment, rating, color);
                    debug("AlbumDAO.get_all collection add new");
                    collection.add(album);
                    break;

                default:
                    critical ("Error parsing database\n");
                    break;
                }
            } while (rc == Sqlite.ROW);
        return collection;
    }

    public Album? get_by_name(string _album_name) {
        //TODO:implement as search
        string query = "SELECT * FROM album WHERE album.album_name = '" + _album_name + "';";
        Statement stmt = db.exec_query(query);
        int rc = -1;
        int cols = stmt.column_count();

        int id = -1;
        string album_name = null;
        int creation_date = -1;
        string comment = null;
        int rating = 0;
        int color = 0;

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
                                album_name = stmt.column_text(col);
                                break;
                            case 2:
                                creation_date = stmt.column_int(col);
                                break;
                            case 3:
                                comment = stmt.column_text(col);
                                break;
                            case 4:
                                rating = stmt.column_int(col);
                                break;
                            case 5:
                                color = stmt.column_int(col);
                                break;
                            default:
                                break;
                        }
                    }
                    Album album = new Album.with_values(id, album_name, creation_date, comment, rating, color);
                    return album;
                default:
                    break;
        }
        return null;
    }


    public bool insert(Album album) {

        debug("AlbumDAO.insert Request\n");

	    DbManager.Data[] values = { new DbManager.Data.from_int(album.id),
                                    new DbManager.Data.from_string(album.album_name),
                                    new DbManager.Data.from_int(album.creation_date),
                                    new DbManager.Data.from_string(album.comment),
                                    new DbManager.Data.from_int((int)album.rating),
                                    new DbManager.Data.from_int((int)album.color)
                                   };
        debug("PictureDAO.insert values generated\n");

	    
        if (db.insert(DbManager.Table.ALBUM, values)) {
            album_inserted(album);
            return true;
        }
        return false;
    }

    public bool edit(Album old_album, Album new_album) {

        return false;
    }

    public bool remove(Album album) {

        return false;
    }


    public static Album? search(Album album_filter) {

        return null;
    }

}