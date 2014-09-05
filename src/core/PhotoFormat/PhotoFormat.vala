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

public enum PhotoFormat {

    JFIF,
    RAW,
    PNG,
    TIFF,
    BMP,
    UNKNOWN;

    // These values are persisted in the database.  DO NOT CHANGE THE INTEGER EQUIVALENTS.
    public int serialize() {
        switch (this) {
            case JFIF:
                return 0;
            
            case RAW:
                return 1;

            case PNG:
                return 2;
            
            case TIFF:
                return 3;

            case BMP:
                return 4;
            
            case UNKNOWN:
            default:
                return -1;
        }
    }
    
    // These values are persisted in the database.  DO NOT CHANGE THE INTEGER EQUIVALENTS.
    public static PhotoFormat unserialize(int value) {
        switch (value) {
            case 0:
                return JFIF;
            
            case 1:
                return RAW;

            case 2:
                return PNG;
            
            case 3:
                return TIFF;

            case 4:
                return BMP;
                            
            default:
                return UNKNOWN;
        }
    }

    // Converts GDK's pixbuf library's name to a PhotoFileFormat
    public static PhotoFormat from_pixbuf_name(string name) {
        switch (name) {
            case "jpeg":
                return PhotoFormat.JFIF;
            
            case "png":
                return PhotoFormat.PNG;
            
            case "tiff":
                return PhotoFormat.TIFF;

            case "bmp":
                return PhotoFormat.BMP;                
            
            default:
                return PhotoFormat.UNKNOWN;
        }
    }

    public static PhotoFormat from_mime_type(string mimetype) {
        switch (mimetype) {
            case "image/jpeg":
                return PhotoFormat.JFIF;
            
            case "image/png":
                return PhotoFormat.PNG;
            
            case "image/tiff":
                return PhotoFormat.TIFF;

            case "image/bmp":
                return PhotoFormat.BMP;                
            
            default:
                return PhotoFormat.UNKNOWN;
        }
    }

    public bool is_suported() {
        if(this == PhotoFormat.UNKNOWN)
            return false;
        return true;
    }


    /*public static PhotoDriver? get_driver() {
        switch (this) {
            case JFIF:
                return new JfifDriver();
            
            case RAW:
                error("Unsupported file format");
            
            case PNG:
                return new PngDriver();
            
            case TIFF:
                return new TiffDriver();
            
            case BMP:
                return new BmpDriver();

            default:
                error("Unsupported file format");
        }

    }*/

}