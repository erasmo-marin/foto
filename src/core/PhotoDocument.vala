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

public class PhotoDocument : GLib.Object {

    public string uri;
    public string name;

    private GLib.File file;
    
    public enum PhotoFileFormat {
        JFIF,
        RAW,
        PNG,
        TIFF,
        BMP,
        UNKNOWN;

        public static PhotoFileFormat[] get_supported() {
            return { JFIF, PNG, TIFF, BMP };
        }

        // Converts GDK's pixbuf library's name to a PhotoFileFormat
        public static PhotoFileFormat from_pixbuf_name(string name) {
            switch (name) {
                case "jpeg":
                    return PhotoFileFormat.JFIF;
                
                case "png":
                    return PhotoFileFormat.PNG;
                
                case "tiff":
                    return PhotoFileFormat.TIFF;

                case "bmp":
                    return PhotoFileFormat.BMP;                
                
                default:
                    return PhotoFileFormat.UNKNOWN;
            }
        }
        

    }
}