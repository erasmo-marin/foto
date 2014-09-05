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

public abstract class CollectionPage : Page {

    protected Gtk.FlowBox box;
    protected Gee.ArrayList<CollectionItem> items;
    protected Gtk.Menu menu;
    protected PictureSorter sorter;
    protected PictureFilter filter;
    protected Gtk.ToggleToolButton search_button;

    public CollectionPage (string page_name, PageContainer container) {

        base (page_name, container);
        this.items = new Gee.ArrayList<CollectionItem>();
        this.expand = true;

        box = new Gtk.FlowBox();
    	box.homogeneous = true;
        box.set_column_spacing(10);
        box.set_row_spacing(10);
	    box.set_border_width (0);
        box.set_selection_mode (Gtk.SelectionMode.MULTIPLE);
        box.set_valign (Gtk.Align.START);
        //box.draw.connect((cr)=>{draw_background(cr,box);return false;});
        box.add_events (Gdk.EventMask.BUTTON_PRESS_MASK);
        box.set_sort_func (sort_func);
        box.set_filter_func (filter_func);
        //FIXME:not working as it should. If the FlowBoxChild is clicked instead 
        //of the CollectionItem, all the selection is unselected but the clicked item.
        box.button_release_event.connect(on_box_button_press);

        box.selected_children_changed.connect(()=>{
            foreach(Gtk.FlowBoxChild child in box.get_selected_children()) {
                (child.get_child() as CollectionItem).is_selected = true;
            }
        });

        setup_toolbars();
        build_context_menu();
        this.add_with_viewport(box);

        box.set_hadjustment (this.get_hadjustment());
        box.set_vadjustment (this.get_vadjustment());

        search_bar.search_changed.connect(()=>{
            box.invalidate_filter ();
        });

    }

    public Gee.ArrayList<CollectionItem> get_selected_items() {
        var collection = new Gee.ArrayList<CollectionItem>();
        foreach(Gtk.FlowBoxChild child in box.get_selected_children ()) {
            collection.add(child.get_child() as CollectionItem);
        }
        return collection;
    }


    public void add_item(CollectionItem item) {
        box.insert(item, -1);
        items.add(item);
        item.selected.connect(()=>{
            box.select_child ((item.get_parent() as Gtk.FlowBoxChild));
        });
        item.unselected.connect(()=>{
            box.unselect_child ((item.get_parent() as Gtk.FlowBoxChild));
        });
    }

    //TODO: How to remove items from flowbox?
    public void remove_all_items() {
        //do it with foreach, dont know how to do it right now
        foreach(Gtk.Widget child in box.get_children()){
            box.remove(child);
            child.destroy();
        }
        items.clear();
    }

    private void setup_toolbars() {
        var zoom_slider = new Foto.Widgets.ZoomSlider();
        zoom_slider.set_range (0.3, 1);
        zoom_slider.set_value(0.6);
        zoom_slider.set_zoom_step (0.05);
        zoom_slider.add_mark_at(0.6);

        zoom_slider.zoom_changed.connect((val)=>{
            foreach(CollectionItem item in items) {
                    debug("Children found\n");
                    item.zoom_request(val);
            }
        });

        search_button = new Gtk.ToggleToolButton();
        search_button.set_icon_name("edit-find-symbolic");
        search_button.margin_top = 5;
        search_button.margin_bottom = 5;

        right_toolbar.add(zoom_slider);
        right_toolbar.add(new Gtk.SeparatorToolItem());
        right_toolbar.add(search_button);

        search_button.toggled.connect(()=>{
            if(search_button.get_active())
                show_search_bar();
            else
                search_bar.set_search_mode(false);
        });
    }

    //draw a nice background
    private bool draw_background (Cairo.Context cr, Gtk.Widget widget) {

        int width = widget.get_allocated_width ();
        int height = widget.get_allocated_height ();

		cr.set_operator (Cairo.Operator.CLEAR);
		cr.paint ();
		cr.set_operator (Cairo.Operator.OVER);
			
        var background_style = get_style_context ();
		background_style.render_background (cr, 0, 0, width, height);
		background_style.render_frame (cr, 0, 0, width, height);

		var pat = new Cairo.Pattern.for_surface (new Cairo.ImageSurface.from_png (Build.PKGDATADIR + "/files/texture.png"));
		pat.set_extend (Cairo.Extend.REPEAT);
		cr.set_source (pat);
		cr.paint_with_alpha (0.6);
			
		return false;
	}

    private bool on_box_button_press(Gdk.EventButton event) {

        if (event.button == 1) {
            unselect_all();
        }
        if (event.button == 3) {
            menu.popup(null, null, null, 1, 0);
        }

        return false;
    }

    private void build_context_menu() {
        //popopver and actions
        var builder = new Gtk.Builder();
        builder.add_from_string(contextual_menu_string, -1);
        GLib.MenuModel menu_model = (GLib.MenuModel) builder.get_object("context-menu");

        menu = new Gtk.Menu.from_model(menu_model);

        var action_group = new GLib.SimpleActionGroup();

        var action_sort_bar = new SimpleAction ("show-sort-bar", null);
        var action_search_bar = new SimpleAction ("show-search-bar", null);

        action_group.add_action(action_sort_bar);
        action_group.add_action(action_search_bar);

        action_sort_bar.activate.connect(()=>{show_sort_bar();});
        action_search_bar.activate.connect(()=>{show_search_bar();});

        menu.insert_action_group("local", action_group);
    }

    public new void show_search_bar() {
        search_button.active = true;
        base.show_search_bar();
    }

    public new void show_sort_bar() {
        search_button.active = false;
        base.show_sort_bar();
    }



    //< 0 if item1 should be before item2, 0 if they are equal and > 0 otherwise
    public abstract int sort_items(CollectionItem item1, CollectionItem item2);

    private int sort_func(Gtk.FlowBoxChild child1, Gtk.FlowBoxChild child2) {
        return sort_items((child1.get_child() as CollectionItem), (child2.get_child() as CollectionItem));
    }

    //true if item should be filtered, false otherwise
    public abstract bool filter_items(CollectionItem item);

    private bool filter_func(Gtk.FlowBoxChild child) {
        return filter_items((child.get_child() as CollectionItem));
    }

    public void invalidate_sort () {
        box.invalidate_sort ();
    }

    public void unselect_all() {
        foreach(var item in items) {
            item.is_selected = false;
        }
    }

    string contextual_menu_string = """<interface>
                                            <menu id='context-menu'>
                                                <item>
                                                    <attribute name='label'>Sort collection</attribute>
                                                    <attribute name='action'>local.show-sort-bar</attribute>
                                                </item>
                                                <item>
                                                    <attribute name='label'>Search collection</attribute>
                                                    <attribute name='action'>local.show-search-bar</attribute>
                                                </item>
                                            </menu>
                                        </interface>""";

}


public class CollectionItem : Gtk.DrawingArea {

    public CollectionPage page;

    private bool _is_selected = false;
    public bool is_selected {
                                 set{
                                     _is_selected = value;
                                     if(value)
                                        selected(this);
                                     else
                                        unselected(this);
                                 } 
                                 get {
                                     return _is_selected;
                                 } 
                             }
 

    public signal void selected(CollectionItem item);
    public signal void unselected(CollectionItem item);
    public signal void zoom_request(double scale);

    public CollectionItem(CollectionPage page) {
        this.page = page;
        add_events (Gdk.EventMask.BUTTON_PRESS_MASK);
        this.button_press_event.connect(on_button_press);
        //avoid propagating the release event
        this.button_release_event.connect(()=>{return true;});
    }

    public bool on_button_press(Gdk.EventButton event) {

        if (event.button == 1 && event.type == Gdk.EventType.@BUTTON_PRESS) {
            if (is_selected) {
                is_selected = false;
            } else {
                is_selected = true;
            }
        }
        return false;
    }

}