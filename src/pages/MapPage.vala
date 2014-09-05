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

using Champlain;
using GtkChamplain;

/* A Page that allows to show photos tagged in a map
 */
public class MapPage : Page {

    MapEmbed map_embed;
    MapView map_view;
    LeveledMarkerLayer markers_layer;

    public MapPage(PageContainer container) {

        base(PageType.MAP_PAGE.to_string(), container);
        markers_layer = new LeveledMarkerLayer.with_view ();
        map_embed = markers_layer.get_embed();
        map_view = markers_layer.get_view();

        //test
        map_view.center_on(-33.00704,-71.26050);
        map_view.zoom_level = 10;

        //end test

        this.add(map_embed);
        setup_toolbars();
    }

    public void setup_toolbars() {
        var zoomin_btn = new Gtk.ToolButton(new Gtk.Image.from_icon_name("zoom-in-symbolic", Gtk.IconSize.MENU),"");
        var zoomout_btn = new Gtk.ToolButton(new Gtk.Image.from_icon_name("zoom-out-symbolic", Gtk.IconSize.MENU),"");
        left_toolbar.add(zoomin_btn);
        left_toolbar.add(zoomout_btn);
        zoomin_btn.clicked.connect (map_view.zoom_in);
        zoomout_btn.clicked.connect (map_view.zoom_out);
    } 
}


/* A replacement for GtkChamplain.Embed with a MapView
 * inside instead a ChamplainView. This class extends
 * from GtkClutter.Embed instead of GtkChamplain.Embed
 * because is not possible to modify the Champlain.View
 * that has an owned get.
 */
public class MapEmbed : GtkClutter.Embed {

    private MapView map_view;

    public MapEmbed () {
        map_view = new MapView();
        get_stage().add_child(map_view);
        size_allocate.connect((allocation) => {
            map_view.set_width(allocation.width);
            map_view.set_height(allocation.height);
        });
    }

    public MapView get_view() {
        return map_view;
    }

}


/*A custom GtkChamplain View
 *with extra functionality
 */
public class MapView : Champlain.View {

    public signal void zoom_changed(uint zoom_level);

    /*private uint _zoom_level;
    public new uint zoom_level { set {
                                        _zoom_level = value;
                                        zoom_changed(value);
                                       }
                                    get {
                                        return _zoom_level;
                                    }
                                }*/
    
    public new void set_zoom_level (uint zoom_level) {
        base.set_zoom_level(zoom_level);
        zoom_changed(this.zoom_level);
    }

    public new void zoom_in() {
        base.zoom_in();
        zoom_changed(zoom_level);
    }

    public new void zoom_out() {
        base.zoom_out();
        zoom_changed(zoom_level);
    }

} 



/* A custom MarkerLayer that can contain
 * different markers deppending of the zoom
 * level in the view, allowing grouping.
 * TODO: implement this as a tree
 */

public class LeveledMarkerLayer : Champlain.MarkerLayer {

    private Gee.ArrayList<MarkerGroupLabel> marker_layers;
    private MapView view;
    private MapEmbed embed;

    public LeveledMarkerLayer.with_view () {
        embed = new MapEmbed();
        view = embed.get_view();
        marker_layers = new Gee.ArrayList<MarkerGroupLabel>();
        view.add_layer(this);
        setup_markers();
        view.zoom_changed.connect((zoom)=> {
            on_zoom_changed();
            print("Layer relocated, current zoom level = %d\n", (int)zoom);
        });
    }

    public LeveledMarkerLayer(MapView view) {
        this.view = view;
        marker_layers = new Gee.ArrayList<MarkerGroupLabel>();
        view.add_layer(this);
        setup_markers();
    }

    private void on_zoom_changed () {
        foreach(MarkerGroupLabel group in marker_layers) {
            foreach(Champlain.Label label in group.get_all_markers()) {
                if(group.level == (int)view.zoom_level)
                    label.animate_in ();
                else
                    label.animate_out ();
            }
        }
    }

    public MapView get_view() {
        return view;
    }

    public MapEmbed? get_embed() {
        return embed;
    }

    public void setup_markers() {

        Clutter.Color orange = Clutter.Color.from_string("#469DD7");

        for(int i= 0; i<17; i++) {

            var group = new MarkerGroupLabel(i);

            var marker_1 = new Champlain.Label.with_text ("5 photos", null, null, null);
            marker_1.set_location(-33.00704,-72.26050);
            marker_1.set_color(orange);

            var marker_2 = new Champlain.Label.with_text ("3 photos ", null, null, null);
            marker_2.set_location(-34.00704,-71.26050);
            marker_2.set_color(orange);

            var marker_3 = new Champlain.Label.with_text ("9 photos", null, null, null);
            marker_3.set_location(-33.00704,-71.26050);
            marker_3.set_color(orange);

            group.add_marker(marker_1);
            group.add_marker(marker_2);
            group.add_marker(marker_3);

            add_marker(marker_1);
            add_marker(marker_2);
            add_marker(marker_3);

            marker_layers.add(group);
        }
    }
}


/*A label marker with more label markers inside
 */
public class MarkerGroupLabel : GLib.Object {

    private Gee.ArrayList<Champlain.Label> childs;
    public int level;
    
    public MarkerGroupLabel(int level) {
        childs = new Gee.ArrayList<Champlain.Label>();
        this.level = level;
    }


    public void add_marker(Champlain.Label marker) {
        childs.add(marker);
    }

    public Gee.ArrayList<Champlain.Label> get_all_markers() {
        return childs;
    }

}