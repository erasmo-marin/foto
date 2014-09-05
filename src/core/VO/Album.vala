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

/* Album is a VO object that represent an album row in the database. 
 * It is used with AlbumDAO, PictureDAO and Photo. VO objects are for moving
 * information between the application layers. No extra operations
 * should be added.
 * Keep it simple.
 */
public class Album : GLib.Object{

    public int? id;
    public string? album_name;
    public int? creation_date;
    public string? comment;
    public uint? rating;
    public uint? color;

    public Album.with_values(int? id, string? album_name, int? creation_date, string? comment, uint? rating, uint? color) {

        this.id = id;
        this.album_name = album_name;
        this.creation_date = creation_date;
        this.comment = comment;
        this.rating = rating;
        this.color = color;

    }

}