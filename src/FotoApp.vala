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

using Granite;
using Granite.Services;

namespace Foto {
    
    // Settings
    //public SavedState saved_state;
    //public Settings settings;
    
    public class FotoApp : Granite.Application {

        public AppWindow window = null;
        public string app_cmd_name { get { return _app_cmd_name; } }
        public static string _app_cmd_name;
        public static bool new_instance = false;
        private static bool print_version = false;
        private static bool create_new_album = false;
        private static bool import_photos = false;
        private static bool about_photos = false;

        construct {
            flags |= ApplicationFlags.HANDLES_OPEN;
            flags |= ApplicationFlags.HANDLES_COMMAND_LINE;
            build_data_dir = Build.DATADIR;
            build_pkg_data_dir = Build.PKGDATADIR;
            build_release_name = Build.RELEASE_NAME;
            build_version = Build.VERSION;
            build_version_info = Build.VERSION_INFO;

            program_name = _("Photos");
            exec_name = "foto";
            app_years = "2012-2014";
            app_icon = "foto";
            app_launcher = "foto.desktop";
            application_id = "org.elementary.foto";
            main_url = "https://launchpad.net/foto";
            bug_url = "https://bugs.launchpad.net/foto";
            help_url = "https://answers.launchpad.net/foto";
            translate_url = "https://translations.launchpad.net/foto";
            about_authors = { "Erasmo Marín <erasmo.marin@gmail.com>",
                         null
                         };
            about_documenters = { "Erasmo Marín <erasmo.marin@gmail.com>",
                              null };
            about_artists = { "Camilo Highita <harveycabaguio@gmail.com>",
                              "Erasmo Marín <erasmo.marin@gmail.com>",
                         null
                         };
            about_translators = "Launchpad Translators";
            about_license_type = Gtk.License.GPL_3_0;
 
        }

        public FotoApp() {

            if(new_instance)
                flags |= ApplicationFlags.NON_UNIQUE;
            set_flags (flags);

            Utils.Cache.init();
         
        }

        protected override int command_line (ApplicationCommandLine command_line) {
            var context = new OptionContext ("File");
            context.add_main_entries (entries, Build.GETTEXT_PACKAGE);
            context.add_group (Gtk.get_option_group (true));

            string[] args = command_line.get_arguments ();
            int unclaimed_args;

            try {
                unowned string[] tmp = args;
                context.parse (ref tmp);
                unclaimed_args = tmp.length - 1;
            } catch(Error e) {
                print (e.message + "\n");

                return Posix.EXIT_FAILURE;
            }

            // Create a new album
            if (create_new_album) {
                activate ();
                create_new_album = false;
                window.action_new_album();
            }

            // Import
            if (import_photos) {
                activate ();
                import_photos = false;
                print("Esta acción no ha sido implementada\n\n");
                //window.main_actions.get_action ("NewTab").activate ();
            }

            // About
            if (import_photos) {
                about_photos = false;
                base.command_line(command_line);
            }

            // Open all files given as arguments
            if (unclaimed_args > 0) {
                File[] files = new File[unclaimed_args];
                files.length = 0;

                foreach (string arg in args[1:unclaimed_args + 1]) {
                    files += File.new_for_commandline_arg (arg);
                }
                open (files, "");
            } else {
                activate ();
            }

            return Posix.EXIT_SUCCESS;
        }

        protected override void activate() {
            if (window == null) {
                window = new AppWindow(this);
                window.show();
            } else {
                window.present();
            }
        }

        protected override void open(File[] files, string hint) {

            var collection = new PictureCollection();
            
            for (int i = 0; i < files.length; i++) {
                try {
                    var info = files[i].query_info ("standard::*", FileQueryInfoFlags.NONE, null);
                    if (info.get_file_type () != FileType.DIRECTORY) {
                        var photo = new Photo.from_file (files[i]);
                        collection.add(photo.get_picture()); 
                    } else {
                        warning ("\"%s\" is a directory, not opening it", files[i].get_basename ());
                    }
                } catch (Error e) {
                    warning (e.message);
                }
            }

            var viewer_window = new ViewerWindow(this, collection);
        }


        static const OptionEntry[] entries = {
            { "new-album", 'n', 0, OptionArg.NONE, out create_new_album, N_("New Album"), null },
            { "import", 'i', 0, OptionArg.NONE, out import_photos, N_("Import photos"), null },
            { "version", 'v', 0, OptionArg.NONE, out print_version, N_("Print version info and exit"), null },
            { "about Photos", 'a', 0, OptionArg.NONE, out about_photos, N_("About Photos"), null },
            { null }
        };

        public static int main(string[] args) {

            _app_cmd_name = "foto";
            var context = new OptionContext ("File");
            context.add_main_entries (entries, Build.GETTEXT_PACKAGE);
            context.add_group (Gtk.get_option_group (true));

            string[] args_primary_instance = args;

            try {
                context.parse (ref args);
            } catch(Error e) {
                print (e.message + "\n");
                return Posix.EXIT_FAILURE;
            }

            if (print_version) {
                stdout.printf ("Foto Album Manager %s\n", Build.VERSION);
                stdout.printf ("Copyright 2013-2014 Foto Developers.\n");

                return Posix.EXIT_SUCCESS;
            }
            var app = new FotoApp();
            GtkClutter.init(ref args);

            return app.run(args_primary_instance);
        }     
    }
}