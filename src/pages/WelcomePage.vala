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

public class WelcomePage : Page {

    private Foto.Widgets.DropArea drop_area;
    private Gtk.Spinner spinner;
    private Gtk.Stack stack;

    public WelcomePage (PageContainer container) {
        base(PageType.WELCOME_PAGE.to_string(), container);
        drop_area = new Foto.Widgets.DropArea(_("Import some Photos"), _("Drop photos here"));
        spinner = new Gtk.Spinner();
        stack = new Gtk.Stack();
        spinner.valign = Gtk.Align.CENTER;
        spinner.halign = Gtk.Align.CENTER;

        stack.add(drop_area);
        stack.add(spinner);

        stack.set_visible_child(drop_area);

        this.add(stack);
        this.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.NEVER);

        drop_area.files_dropped.connect((files) => {
            stack.set_visible_child(spinner);
            spinner.start();
            ImportJob import = ImportJob.get_instance(files);
            import.start_import();
            import.thread_end.connect(()=>{
                print("Import finished\n");
                container.switch_to_page(PageType.LAST_IMPORTED_PAGE);
                while(Gtk.events_pending())
                    Gtk.main_iteration();
                stack.set_visible_child(drop_area);
            });
        });
    }

}