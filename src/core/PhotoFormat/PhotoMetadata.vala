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

using GExiv2;
using Exif;

public enum MetadataDomain {
    EXIF,
    XMP,
    IPTC,
    UNKNOWN;
}

public enum Orientation {
    MIN = 1,
    TOP_LEFT = 1,
    TOP_RIGHT = 2,
    BOTTOM_RIGHT = 3,
    BOTTOM_LEFT = 4,
    LEFT_TOP = 5,
    RIGHT_TOP = 6,
    RIGHT_BOTTOM = 7,
    LEFT_BOTTOM = 8,
    MAX = 8
}

public class PhotoMetadata {

    private GExiv2.Metadata exiv2 = new GExiv2.Metadata();
    private Exif.Data? exif = null;
    private Picture picture;
    private const int[] rating_thresholds = { 0, 1, 25, 50, 75, 99 };

    private static string[] DATE_TIME_TAGS = {
        "Exif.Image.DateTime",
        "Xmp.tiff.DateTime",
        "Xmp.xmp.ModifyDate"
    };

    private static string[] EXPOSURE_DATE_TIME_TAGS = {
        "Exif.Photo.DateTimeOriginal",
        "Xmp.exif.DateTimeOriginal",
        "Xmp.xmp.CreateDate",
        "Exif.Photo.DateTimeDigitized",
        "Xmp.exif.DateTimeDigitized",
        "Exif.Image.DateTime"
    };

    private static string[] DIGITIZED_DATE_TIME_TAGS = {
        "Exif.Photo.DateTimeDigitized",
        "Xmp.exif.DateTimeDigitized"
    };

    private static string[] WIDTH_TAGS = {
        "Exif.Photo.PixelXDimension",
        "Xmp.exif.PixelXDimension",
        "Xmp.tiff.ImageWidth",
        "Xmp.exif.PixelXDimension"
    };
    
    public static string[] HEIGHT_TAGS = {
        "Exif.Photo.PixelYDimension",
        "Xmp.exif.PixelYDimension",
        "Xmp.tiff.ImageHeight",
        "Xmp.exif.PixelYDimension"
    };

    private const string IPHOTO_TITLE_TAG = "Iptc.Application2.ObjectName";
    
    private static string[] STANDARD_TITLE_TAGS = {
        "Iptc.Application2.Caption",
        "Xmp.dc.title",
        "Iptc.Application2.Headline",
        "Xmp.photoshop.Headline"
    };

    private static string[] KEYWORD_TAGS = {
        "Xmp.dc.subject",
        "Iptc.Application2.Keywords"
    };

    private static string[] ARTIST_TAGS = {
        "Exif.Image.Artist",
        "Exif.Canon.OwnerName" // Custom tag used by Canon DSLR cameras
    };

    private static string[] RATING_TAGS = {
        "Xmp.xmp.Rating",
        "Iptc.Application2.Urgency",
        "Xmp.photoshop.Urgency",
        "Exif.Image.Rating"
    };

    public PhotoMetadata.from_file(GLib.File file) {
        exiv2 = new GExiv2.Metadata();
        exif = null;
        
        exiv2.open_path(file.get_parse_name());
        exif = Exif.Data.new_from_file(file.get_parse_name());

        this.picture = null;

    }


    public PhotoMetadata(Picture picture) {
        exiv2 = new GExiv2.Metadata();
        exif = null;
        
        exiv2.open_path(picture.file_path);
        exif = Exif.Data.new_from_file(picture.file_path);

        this.picture = picture;
    }

    public static MetadataDomain get_tag_domain(string tag) {
        if (GExiv2.Metadata.is_exif_tag(tag))
            return MetadataDomain.EXIF;
        
        if (GExiv2.Metadata.is_xmp_tag(tag))
            return MetadataDomain.XMP;
        
        if (GExiv2.Metadata.is_iptc_tag(tag))
            return MetadataDomain.IPTC;
        
        return MetadataDomain.UNKNOWN;
    }

    public bool has_domain(MetadataDomain domain) {
        switch (domain) {
            case MetadataDomain.EXIF:
                return exiv2.has_exif();
            
            case MetadataDomain.XMP:
                return exiv2.has_xmp();
            
            case MetadataDomain.IPTC:
                return exiv2.has_iptc();
            
            case MetadataDomain.UNKNOWN:
            default:
                return false;
        }
    }

    public bool has_exif() {
        return has_domain(MetadataDomain.EXIF);
    }
    
    public bool has_xmp() {
        return has_domain(MetadataDomain.XMP);
    }
    
    public bool has_iptc() {
        return has_domain(MetadataDomain.IPTC);
    }

    public bool can_write_to_domain(MetadataDomain domain) {
        switch (domain) {
            case MetadataDomain.EXIF:
                return exiv2.get_supports_exif();
            
            case MetadataDomain.XMP:
                return exiv2.get_supports_xmp();
            
            case MetadataDomain.IPTC:
                return exiv2.get_supports_iptc();
            
            case MetadataDomain.UNKNOWN:
            default:
                return false;
        }
    }

    public bool can_write_exif() {
        return can_write_to_domain(MetadataDomain.EXIF);
    }
    
    public bool can_write_xmp() {
        return can_write_to_domain(MetadataDomain.XMP);
    }
    
    public bool can_write_iptc() {
        return can_write_to_domain(MetadataDomain.IPTC);
    }

    /*Get functions*/

    //strings
    public string? get_string(string tag) {
        return exiv2.get_tag_string(tag);
    }
    
    public string? get_string_interpreted(string tag) {
        return exiv2.get_tag_interpreted_string(tag);
    }

    public string? get_first_string(string[] tags) {
        foreach (string tag in tags) {
            string? value = get_string(tag);
            if (value != null)
                return value;
        }
        
        return null;
    }
    
    public string? get_first_string_interpreted(string[] tags) {
        foreach (string tag in tags) {
            string? value = get_string_interpreted(tag);
            if (value != null)
                return value;
        }
        
        return null;
    }

    //long
    public bool get_long(string tag, out long value) {
        if (!has_tag(tag)) {
            value = 0;
            
            return false;
        }
        
        value = exiv2.get_tag_long(tag);
        
        return true;
    }
    
    public bool get_first_long(string[] tags, out long value) {
        foreach (string tag in tags) {
            if (get_long(tag, out value))
                return true;
        }
        
        value = 0;
        
        return false;
    }


    //rational
    public bool get_rational(string tag, out int numerator, out int denominator) {
        return exiv2.get_exif_tag_rational(tag, out numerator, out denominator);
    }

    public bool get_first_rational(string[] tags, out int numerator, out int denominator) {
        foreach (string tag in tags) {
            if (get_rational(tag, out numerator, out denominator))
                return true;
        }
        numerator = 0;
        denominator = 0;
        return false;
    }

    /*Set functions*/

    //strings
    public void set_string(string tag, string value) {

        if (value == null) {
            warning("Not setting tag %s to string %s", tag, value);
            return;
        }
        
        if (!exiv2.set_tag_string(tag, value))
            warning("Unable to set tag %s to string %s from source %s", tag, value, picture.file_path);
    }

    //long
    public void set_long(string tag, long value) {
        if (!exiv2.set_tag_long(tag, value))
            warning("Unable to set tag %s to long %ld from source %s", tag, value, picture.file_path);
    }

    
    public bool has_tag(string tag) {
        return exiv2.has_tag(tag);
    }


    public string? get_tag_label(string tag) {
        return GExiv2.Metadata.get_tag_label(tag);
    }
    
    public string? get_tag_description(string tag) {
        return GExiv2.Metadata.get_tag_description(tag);
    }

    public void remove_tag(string tag) {
        exiv2.clear_tag(tag);
    }
    
    public void remove_tags(string[] tags) {
        foreach (string tag in tags)
            remove_tag(tag);
    }

    public void clear_domain(MetadataDomain domain) {
        switch (domain) {
            case MetadataDomain.EXIF:
                exiv2.clear_exif();
            break;
            
            case MetadataDomain.XMP:
                exiv2.clear_xmp();
            break;
            
            case MetadataDomain.IPTC:
                exiv2.clear_iptc();
            break;
        }
    }




    //The useful functions

    public bool has_orientation() {
        return exiv2.get_orientation() == GExiv2.Orientation.UNSPECIFIED;
    }
    
    // If not present, returns Orientation.TOP_LEFT.
    public Orientation get_orientation() {
        // GExiv2.Orientation is the same value-wise as Orientation, with one exception:
        // GExiv2.Orientation.UNSPECIFIED must be handled
        GExiv2.Orientation orientation = exiv2.get_orientation();
        if (orientation ==  GExiv2.Orientation.UNSPECIFIED || orientation < Orientation.MIN ||
            orientation > Orientation.MAX)
            return Orientation.TOP_LEFT;
        else
            return (Orientation) orientation;
    }
    
    public void set_orientation(Orientation orientation) {
        // GExiv2.Orientation is the same value-wise as Orientation
        exiv2.set_orientation((GExiv2.Orientation) orientation);
    }

    public string? get_comment() {
        return chomp_chug(get_string_interpreted("Exif.Photo.UserComment"));
    }
    
    public void set_comment(string? comment) {
        set_string("Exif.Photo.UserComment", comment);
    }

    public bool get_exposure(out int numerator, out int denominator) {
        return get_rational("Exif.Photo.ExposureTime", out numerator, out denominator);
    }

    public string? get_exposure_string() {
        int exposure_numerator;
        int exposure_denominator;

        if (!get_rational("Exif.Photo.ExposureTime", out exposure_numerator, out exposure_denominator))
            return null;

        return chomp_chug(get_string_interpreted("Exif.Photo.ExposureTime"));
    }
    
    public bool get_iso(out long iso) {
        bool fetched_ok = get_long("Exif.Photo.ISOSpeedRatings", out iso);

        if (fetched_ok == false)
            return false;
        
        // lower boundary is original (ca. 1935) Kodachrome speed, the lowest ISO rated film ever
        // manufactured; upper boundary is 4 x fastest high-speed digital camera speeds
        if ((iso < 6) || (iso > 409600))
            return false;
        
        return true;
    }
    
    public string? get_iso_string() {
        long iso;
        if (!get_iso(out iso))
            return null;

        return chomp_chug(get_string_interpreted("Exif.Photo.ISOSpeedRatings"));
    }

    public bool get_aperture(out int aperture_numerator, out int aperture_denominator) {
        return get_rational("Exif.Photo.FNumber", out aperture_numerator, out aperture_denominator);
    }
    
    public string? get_aperture_string(bool pango_formatted = false) {

        int aperture_num;
        int aperture_den;

        if (!get_aperture(out aperture_num, out aperture_den))
            return null;
        
        double aperture_value = ((double) aperture_num) / ((double) aperture_den);
        aperture_value = ((int) (aperture_value * 10.0)) / 10.0;

        return chomp_chug((pango_formatted ? "<i>f</i>/" : "f/") + 
            ((aperture_value % 1 == 0) ? "%.0f" : "%.1f").printf(aperture_value));
    }
    
    public string? get_camera_make() {
        return chomp_chug(get_string_interpreted("Exif.Image.Make"));
    }
    
    public string? get_camera_model() {
        return chomp_chug(get_string_interpreted("Exif.Image.Model"));
    }
    
    //FIXME
    public bool get_flash(out long flash) {
        // Exif.Image.Flash does not work for some reason
        return get_long("Exif.Photo.Flash", out flash);
    }
    
    public string? get_flash_string() {
        // Exif.Image.Flash does not work for some reason
        return chomp_chug(get_string_interpreted("Exif.Photo.Flash"));
    }
    
    public bool get_focal_length(out int focal_num, out int focal_den) {
        return get_rational("Exif.Photo.FocalLength", out focal_num, out focal_den);
    }
    
    public string? get_focal_length_string() {
        return chomp_chug(get_string_interpreted("Exif.Photo.FocalLength"));
    }

    public string? get_artist() {
        return chomp_chug(get_first_string_interpreted(ARTIST_TAGS));
    }
    
    public string? get_copyright() {
        return chomp_chug(get_string_interpreted("Exif.Image.Copyright"));
    }
    
    public string? get_software() {
        return chomp_chug(get_string_interpreted("Exif.Image.Software"));
    }

    public void set_software(string software, string version) {
        // always set this one, even if EXIF not present
        set_string("Exif.Image.Software", "%s %s".printf(software, version));
        
        if (has_iptc()) {
            set_string("Iptc.Application2.Program", software);
            set_string("Iptc.Application2.ProgramVersion", version);
        }
    }
    
    public void remove_software() {
        remove_tag("Exif.Image.Software");
        remove_tag("Iptc.Application2.Program");
        remove_tag("Iptc.Application2.ProgramVersion");
    }
    
    public string? get_exposure_bias() {
        return chomp_chug(get_string_interpreted("Exif.Photo.ExposureBiasValue"));
    }  

    public int get_rating() {
        string? rating_string = get_first_string(RATING_TAGS);
        if(rating_string != null)
            return int.parse(rating_string);

        rating_string = get_string("Exif.Image.RatingPercent");
        if(rating_string == null) {
            return 0;
        }

        int int_percent_rating = int.parse(rating_string);
        for(int i = 5; i >= 0; --i) {
            if(int_percent_rating >= rating_thresholds[i])
                return i;
        }
        return 0;
    }

    public void set_rating(int rating) {
        set_string("Xmp.xmp.Rating", rating.to_string());
        set_string("Exif.Image.Rating", rating.to_string());

        if( 0 <= rating )
            set_string("Exif.Image.RatingPercent", rating_thresholds[rating].to_string());
        else // in this case we _know_ int_rating is -1
            set_string("Exif.Image.RatingPercent", rating.to_string());
    }




}