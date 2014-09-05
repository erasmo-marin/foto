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


/*
 * This class allow to acces to commmon used operations over a photo
 * like loading from hard disk, getting and editing metadata, and useful
 * file utilities. This should support also filters and non-destructive 
 * editing and face recognition functions.
 * It uses a Picture VO object to load all the needed information. Also, it
 * can be constructed from a GLib.File, convenient for imports.
 */

public class Photo {

    private PhotoMetadata metadata;
    private Picture picture;
    private PhotoFormat format;
    private PhotoDriver driver;
    private GLib.File file;
    private GLib.FileInfo fileinfo;

    //TODO: PhotoFormat and driver
    public Photo (Picture picture) {
        this.picture = picture;
        file = GLib.File.new_for_commandline_arg (picture.file_path);
        fileinfo = file.query_info ("standard::*", 0, null);
        format = PhotoFormat.from_mime_type(get_mime_type());
    }

    public Photo.from_file (GLib.File file) {
        this.file = file;
        fileinfo = file.query_info ("standard::*", 0, null);
        format = PhotoFormat.from_mime_type(get_mime_type());
    }


    public string get_filename() {
        return picture.file_path;
    }

    public string get_basename() {
        return file.get_basename();
    }

    public string get_mime_type() {
        string content = fileinfo.get_content_type ();
        string mimetype = GLib.ContentType.get_mime_type(content);

        return mimetype;
    }


    public bool is_supported() {
        if(format == PhotoFormat.UNKNOWN)
            return false;
        return true;
    }

    public string get_user_visible_name() {
        return file.get_basename();
    }

    public string get_path() {
        return file.get_path();
    }

    public PhotoDriver? get_driver() {
        return null;
    }

    public PhotoFormat? get_format() {
        return null;
    }

    public PhotoMetadata get_metadata() {
        if(metadata == null)
            if(picture != null)
                metadata = new PhotoMetadata(picture);
            else
                metadata = new PhotoMetadata.from_file(file);

        return metadata;
    }

    //if picture is null, this function will build a valid picture
    //Importan: the import date atribute will not be asigned
    public Picture get_picture() {

        if(picture != null)
            return this.picture;

        Picture pic = new Picture();
        pic.file_path = file.get_parse_name ();
        pic.rating = get_metadata().get_rating();
        pic.comment = get_metadata().get_comment();
        return pic;
    }

}