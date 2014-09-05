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

using Gdk;
using GLib;

namespace Utils{

    public class IconFactory {

        public enum IconType {

            CAMERA_ITEM,
            PICTURES_ITEM,

            ICON_CLOSE_BUTTON,
            ICON_EDIT_BUTTON,
            ICON_IMAGE_LOADING,
            ICON_IMAGE_MISSING,

            STAR_ACTIVE,
            STAR_INACTIVE,
            STAR_PRELIGHT,/*Still not implemented*/

            STAR_ACTIVE_SYMBOLIC,
            STAR_INACTIVE_SYMBOLIC,
            STAR_PRELIGHT_SYMBOLIC /*Still not implemented*/

        }

        //sidebar items
        private static Gdk.Pixbuf CAMERA_ITEM;
        private static Gdk.Pixbuf PICTURES_ITEM;
        //Thumb elements
        private static Gdk.Pixbuf ICON_CLOSE_BUTTON;
        private static Gdk.Pixbuf ICON_EDIT_BUTTON;
        private static Gdk.Pixbuf ICON_IMAGE_LOADING;
        private static Gdk.Pixbuf ICON_IMAGE_MISSING;
        //rating
        private static Gdk.Pixbuf STAR_ACTIVE;
        private static Gdk.Pixbuf STAR_INACTIVE;
        private static Gdk.Pixbuf STAR_PRELIGHT;
        //rating prelight
        private static Gdk.Pixbuf STAR_ACTIVE_SYMBOLIC;
        private static Gdk.Pixbuf STAR_INACTIVE_SYMBOLIC;
        private static Gdk.Pixbuf STAR_PRELIGHT_SYMBOLIC;

        private static bool initialized = false;

        public IconFactory() {
            if(!initialized) {
                init();
                initialized = true;
            }
        }

        protected static void init() {

        	try {

                CAMERA_ITEM = new Gdk.Pixbuf.from_file(Build.PKGDATADIR + "/foto-camera-item.png");
                PICTURES_ITEM = new Gdk.Pixbuf.from_file(Build.PKGDATADIR + "/foto-pictures-item.png");
                
                ICON_CLOSE_BUTTON = new Gdk.Pixbuf.from_file(Build.PKGDATADIR + "/close-button.png");
                ICON_EDIT_BUTTON = new Gdk.Pixbuf.from_file(Build.PKGDATADIR + "/edit-button.png");
                ICON_IMAGE_LOADING = new Gdk.Pixbuf.from_file(Build.PKGDATADIR + "/image-loading.png");
                ICON_IMAGE_MISSING = new Gdk.Pixbuf.from_file(Build.PKGDATADIR + "/image-missing.png");

                STAR_ACTIVE = new Gdk.Pixbuf.from_file(Build.PKGDATADIR + "/star-active.png");
                STAR_INACTIVE = new Gdk.Pixbuf.from_file(Build.PKGDATADIR + "/star-inactive.png");
                STAR_PRELIGHT = new Gdk.Pixbuf.from_file(Build.PKGDATADIR + "/star-prelight.png");

                STAR_ACTIVE_SYMBOLIC = new Gdk.Pixbuf.from_file(Build.PKGDATADIR + "/star-active-symbolic.png");
                STAR_INACTIVE_SYMBOLIC = new Gdk.Pixbuf.from_file(Build.PKGDATADIR + "/star-inactive-symbolic.png");
                STAR_PRELIGHT_SYMBOLIC = new Gdk.Pixbuf.from_file(Build.PKGDATADIR + "/star-prelight-symbolic.png");

			} catch (GLib.Error error) {
                 warning("There was a problem loading icons.");
		    }

        }

        //static method to get icons
        public static Gdk.Pixbuf? get_icon(IconType icon_type) {

                if(!initialized) {
                    init();
                    initialized = true;
                }

                switch (icon_type) {

                    case IconType.CAMERA_ITEM:
                        return CAMERA_ITEM;

                    case IconType.PICTURES_ITEM:
                        return PICTURES_ITEM;

                    case IconType.ICON_CLOSE_BUTTON:
                        return ICON_CLOSE_BUTTON;

                    case IconType.ICON_EDIT_BUTTON:
                        return ICON_EDIT_BUTTON;

                    case IconType.ICON_IMAGE_LOADING:
                        return ICON_IMAGE_LOADING;

                    case IconType.ICON_IMAGE_MISSING:
                        return ICON_IMAGE_MISSING;

                    case IconType.STAR_ACTIVE:
                        return STAR_ACTIVE;

                    case IconType.STAR_INACTIVE:
                        return STAR_INACTIVE;

                    case IconType.STAR_PRELIGHT:
                        return STAR_PRELIGHT;

                    case IconType.STAR_ACTIVE_SYMBOLIC:
                        return STAR_ACTIVE_SYMBOLIC;

                    case IconType.STAR_INACTIVE_SYMBOLIC:
                        return STAR_INACTIVE_SYMBOLIC;

                    case IconType.STAR_PRELIGHT_SYMBOLIC:
                        return STAR_PRELIGHT_SYMBOLIC;

                    default:
                        assert_not_reached();
                }
        }
    }
}