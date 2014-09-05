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

using Gtk;

namespace Foto.Widgets{

    public class MainMenu : Gtk.Menu {
		
	public Gtk.MenuItem preferences;
	private Gtk.CheckMenuItem m_fullscreen;
    private AppWindow window;
    public bool options;
        
        public MainMenu () {
			//bool
			this.options = false;
			this.preferences = new Gtk.MenuItem.with_label(_("Options"));
			this.m_fullscreen = new Gtk.CheckMenuItem.with_label (_("Fullscreen"));

			append(preferences);
			append(m_fullscreen);
        }		
		

	public void set_new_window(AppWindow window){
		this.window = window;
		preferences.activate.connect ( () => toggle_options () );
		this.m_fullscreen.toggled.connect (toggle_fullscreen);
	}

	private void toggle_fullscreen () {
		
		if (m_fullscreen.get_active()){
			this.window.fullscreen ();
		} else{
			this.window.unfullscreen ();
		}
	}
		
	private void toggle_options(){	
		/*var dialog = new SettingsDialog();
		
		dialog.response.connect((response)=>{
        	//IF CLOSE
        	if(response == ResponseType.CLOSE)
        		dialog.destroy();
        });
        dialog.run();*/
	}
		
	}
}