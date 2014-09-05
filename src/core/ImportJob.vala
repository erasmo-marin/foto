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
using GLib;

public class ImportJob : GLib.Object, Thredeable {

    private static ImportJob self;
    private static File[] files;

    private ImportJob(File[] files) {
        this.files = files;
    }

    public static ImportJob get_instance(File[] files) {
        
        if(self == null)
            return new ImportJob(files);
        self.files = files;
        return self;
    }

    public void start_import() {
        start_job();
    }

    //TODO implement filter
    public void job_func () {

        var date = new DateTime.now_local ();
        int import_date = (int)date.to_unix();
        int duplicated = 0;
        PictureDAO picdao = PictureDAO.get_instance();
        var metadata = new Metadata();

        foreach(File file in files) {

            debug("Importing %s\n", file.get_parse_name ());
            var photo = new Photo.from_file(file);

            if(!photo.is_supported()) {
                debug("File not supported found");
                continue;
            }

            Picture pic = photo.get_picture();
            pic.import_date = import_date;
            
            if(!picdao.insert(pic)) {
                debug("No se pudo insertar %s, archivo duplicado?", pic.file_path);
                duplicated++;
            }

        }

    }

}



//An interface that makes easier to use simple threads. Just implement job_func() to go.
public interface Thredeable : GLib.Object {

    public signal void thread_end();

    public bool start_job() {
        try {
            Thread<void*> thread_a = new Thread<void*>.try ("thread_a", this.thread_func);
        } catch (Error e) {
            stderr.printf ("%s\n", e.message);
            return false;
        }
        return true;
    }


    public void* thread_func () {
        job_func();
        thread_end();
        return null;
    }

    public abstract void job_func();

}