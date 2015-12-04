import sys
from gi.repository import Gtk, Gdk, GLib, AppIndicator3 as appindicator
from datetime import datetime
from functools import partial


class Applet:
    def __init__(self, data_base, limit=5, timeout_timer=5, timeout=30):
        self.timeout = timeout
        self.limit = limit
        self.count = 0
        self.db = data_base
        self.timeout_timer = timeout_timer
        self.timeout = timeout

    def show(self):
        self.ind = self._make_indicator()
        self._download_messages()
        self.menu = self._make_menu()

        self.ind.set_menu(self.menu)
        self.menu.show_all()
        GLib.timeout_add_seconds(self.timeout_timer, self._update)
        Gtk.main()

    def _sub_menu(self, menu_items, menu, msg):
        sub_menu = Gtk.Menu()
        item1 = Gtk.MenuItem('ignore')
        item2 = Gtk.MenuItem('answer')

        func = partial(self._ignore, menu_item=menu_items, menu=menu, msg=msg)
        item1.connect('activate', func)
        item2.connect('activate', self.answer)

        sub_menu.append(item1)
        sub_menu.append(item2)

        return sub_menu

    def _make_block_menu(self, name, messages, menu):
        title = Gtk.MenuItem(name + ":")
        menu.append(title)

        for msg in messages:
            menu_items = Gtk.MenuItem(self._make_label(msg))
            menu_items.set_submenu(self._sub_menu(menu_items, menu, msg))
            menu.append(menu_items)
        sep_menu = Gtk.SeparatorMenuItem()
        menu.append(sep_menu)

    def _make_indicator(self):
        ind = appindicator.Indicator.new("example-simple-client",
                                         "indicator-messages",
                                         appindicator.IndicatorCategory.APPLICATION_STATUS)
        ind.set_status(appindicator.IndicatorStatus.ACTIVE)
        ind.set_attention_icon("indicator-messages-new")
        return ind

    def answer(self, widget):
        print 'answer'

    def _ignore(self, widget, menu_item, menu, msg):
        self.db.add_ignored(msg)
        menu.remove(menu_item)

    def _make_menu(self):
        blocks = (('Recently', self.recently), ('Long', self.long),
                  ('Long long', self.long_long))
        menu = Gtk.Menu()
        for name, messages in blocks:
            self._make_block_menu(name, messages, menu)
        menu.append(self._make_quit())
        return menu

    def _update(self):
        self._download_messages()
        self.menu = self._make_menu()
        self.ind.set_menu(self.menu)
        self.menu.show_all()
        return True

    def _make_quit(self):
        quit_item = Gtk.MenuItem("Quit")
        quit_item.connect("activate", self._quit)
        return quit_item
    def _download_messages(self):
        self.recently, self.long, self.long_long = self.db.get_messages()

    def _make_label(self, msg):
        label = "{} : {} time:{}:{}:{}"
        sec = int((datetime.now() - msg.date).total_seconds())

        hour = sec // 3600
        minutes = (sec - hour * 3600) // 60
        sec = (sec - hour * 3600 - minutes * 60)

        return label.format(msg.to, msg.sender, hour, minutes, sec)

    def _quit(self, widget):
        sys.exit(0)