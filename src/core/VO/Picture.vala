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

/* Picture is a VO object that represent a picture row in the database. 
 * It is used with PictureDAO and Photo. VO objects are for moving
 * information between the application layers. No extra operations
 * should be added.
 * Keep it simple.
 */
public class Picture : GLib.Object{

    public int? id;
    public string? file_path;
    public int? import_date;
    public string[]? tags;
    public string? thumbnail_md5;
    public uint? rating;
    public string? comment;
    public int? album_id;


    public Picture.with_values(int? id, string? file_path, int? import_date, 
                                string[]? tags, string? thumbnail_md5, uint? rating, 
                                string? comment, int? album_id) {

        this.id = id;
        this.file_path = file_path;
        this.import_date = import_date;
        this.tags = tags;
        this.thumbnail_md5 = thumbnail_md5;
        this.comment = comment;
        this.rating = rating;
        this.album_id = album_id;
    }

}