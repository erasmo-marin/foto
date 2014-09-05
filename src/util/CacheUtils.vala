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
using Gdk;
using GLib;
using Gee;

//TODO: Save cache images async
namespace Utils{

    public class Cache {

        static string cache_folder = null;
        static HashMap<string,Pixbuf> images = null;

        public async static void init () {
            if (cache_folder == null)
                cache_folder = Environment.get_user_cache_dir () + "/foto/";
            if (images == null) {
                images = new HashMap<string, Pixbuf>();
                GLib.FileInfo file_info = null;
                var image_folder = File.new_for_path (cache_folder);
                try {
                    var enumerator = image_folder.enumerate_children(FileAttribute.STANDARD_NAME + "," 
								        + FileAttribute.STANDARD_TYPE, 0);
                    // While there's still files left to count
                    while ((file_info = enumerator.next_file ()) != null) {

                        try {
                            Pixbuf image;
                            GLib.File file = GLib.File.new_for_commandline_arg (get_cache_path () + file_info.get_name());
	                        GLib.InputStream stream = yield file.read_async ();
	                        image = yield new Pixbuf.from_stream_async (stream, null);
                            images.set(file_info.get_name(), image);
                        } catch (GLib.Error err) {
                 	       stdout.printf ("%s\n", err.message);
                        }
                    }
                } catch(GLib.Error err) {
                    // Just for debugging sake
                    debug("Could not pre-scan folder. Progress percentage may be off: %s\n", err.message);
                }
            }

        }

        /*create a new cache for image path*/
        public static bool cache_image (string image_path, int width, int height) {
            try {
                Cache.init.begin();
                var pixbuf = new Pixbuf.from_file_at_scale (image_path, width, height, true);
                debug ("Image cached: " + get_cache_path () + compute_key (image_path));
                pixbuf.save (get_cache_path () + compute_key (image_path) , "png");
                images.set(compute_key (image_path), pixbuf);
            } catch (GLib.Error err) {
     	        warning("cache_image failed");
                return false;
            }
            return true;
        }

        public static bool cache_image_pixbuf (Pixbuf pixbuf, string image_path) {
            try {
                Cache.init.begin();
                pixbuf.save (get_cache_path () + compute_key (image_path) , "png");
                images.set(compute_key (image_path), pixbuf);
            } catch (GLib.Error err) {
     	        warning("cache_image_pixbuf failed");
                return false;
            }
            return true;
        }


        /*Determine if a image is cached*/
        public static bool is_cached (string image_path) {
            Cache.init.begin();
            File file = File.new_for_path (get_cache_path () + compute_key (image_path));
            if (!file.query_exists ())
                return false;
            return true;
        }

        /*this returns the cached thumbnail.**/
        public static Pixbuf? get_cached_image (string image_path) {
            Cache.init.begin();
            string computed_key = compute_key (image_path);
            if (images.has_key(computed_key))
                return images.get(computed_key);

            Pixbuf pixbuf = null;
            try {
                pixbuf = new Pixbuf.from_file (get_cache_path () + computed_key);
            } catch (GLib.Error err) {
     	        warning("get_cached_image failed");
                return null;
            }
            images.set(computed_key, pixbuf);
            return pixbuf;
        }

        //FIXME
        public async static Pixbuf? get_cached_image_async (string image_path) {
            Cache.init.begin();
            string computed_key = compute_key (image_path);
            if (images.has_key(computed_key))
                return images.get(computed_key);
            
            Pixbuf image;
            GLib.File file = GLib.File.new_for_commandline_arg (get_cache_path () + computed_key);
            try {
	            GLib.InputStream stream = yield file.read_async ();
	            image = yield new Pixbuf.from_stream_async (stream, null);
                images.set(computed_key, image);
                return image;
            } catch (GLib.Error err) {
     	        warning("get_cached_image_async failed with file %s", image_path);
                return null;
            }
        }

        public static async void empty_cache () {
            debug ("Start deleting cache\n");
            var dir = File.new_for_path (cache_folder);
            try {
                // asynchronous call, to get directory entries
                var e = yield dir.enumerate_children_async (FileAttribute.STANDARD_NAME,
                                                        0, Priority.DEFAULT);
                while (true) {
                    // asynchronous call, to get entries so far
                    var files = yield e.next_files_async (10, Priority.DEFAULT);
                    if (files == null) {
                        break;
                    }
                    // append the files found so far to the list
                    foreach (var info in files) {
                        var file = dir.get_child (info.get_name ());
                        file.delete();
                    }
                }
            } catch (Error err) {
                warning("empy_cache failes");
            } finally {
                clean_memory();
            }
        }

        public static void clean_memory() {
            images.clear();
        }


        /*
        * Compute the key from an image path
        */
        private static string compute_key (string image_path) {
            return Checksum.compute_for_string (ChecksumType.MD5, image_path);
        }

        private static string get_cache_path () {
            Cache.init.begin ();
            return cache_folder;
        }
    }
}