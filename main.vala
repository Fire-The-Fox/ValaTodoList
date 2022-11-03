int main (string[] argv) {
    GLib.GenericArray<string> todos = new GLib.GenericArray<string>();

    var app = new Gtk.Application("com.firethefox.todo", GLib.ApplicationFlags.FLAGS_NONE);

    File file = File.new_for_path("todo-data");

    bool tmp = file.query_exists();

    if (tmp == false) {
        file.create(FileCreateFlags.NONE);
    } else {
        try {
            FileInputStream @is = file.read();
            DataInputStream dis = new DataInputStream(@is);
            string line;
    
            while ((line = dis.read_line ()) != null) {
                todos.add(line);
            }
        } catch (Error e) {
            print ("Error: %s\n", e.message);
        }
    }

    app.activate.connect (() => {
        var window = new Gtk.ApplicationWindow(app);
        var main = new Gtk.Box(Gtk.Orientation.VERTICAL, 2);
        var entry = new Gtk.Entry();

        var list = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);

        entry.set_margin_bottom(7);
        entry.set_margin_top(7);
        entry.set_margin_start(7);
        entry.set_margin_end(7);

        todos.foreach((str) => {
            var itemBase = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 4);
            var item = new Gtk.Label(str);
            var itemButton = new Gtk.CheckButton();

            itemButton.toggled.connect(() => {
                for (int i = 0; i < todos.length; i++) {
                    if (todos[i] == str) {
                        todos.remove_index(i);
                        break;
                    }
                }
                if (itemButton.active) {
                    item.set_markup("<span strikethrough=\"true\">" + item.label + "</span>");
                } else {
                    item.set_markup(str);
                }
            });

            itemBase.set_margin_start(7);
            itemBase.set_margin_end(7);
            itemBase.set_margin_bottom(7);

            itemBase.append(itemButton);
            itemBase.append(item);

            list.append(itemBase);
        });

        entry.activate.connect (() => {
            if (entry.text.length == 0) {
                return;
            }

            todos.add(entry.text);
            var temp = "";

            var itemBase = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 4);
            var item = new Gtk.Label(entry.text);
            var itemButton = new Gtk.CheckButton();
            
            entry.text = "";

            itemButton.toggled.connect(() => {
                for (int i = 0; i < todos.length; i++) {
                    if (todos[i] == item.label) {
                        todos.remove_index(i);
                        break;
                    }
                }
                if (itemButton.active) {
                    temp = item.label;
                    item.set_markup("<span strikethrough=\"true\">" + item.label + "</span>");
                } else {
                    todos.add(temp);
                    item.set_markup(temp);
                }
            });

            itemBase.set_margin_start(7);
            itemBase.set_margin_end(7);
            itemBase.set_margin_bottom(7);

            itemBase.append(itemButton);
            itemBase.append(item);

            list.append(itemBase);
		});

        main.append(entry);
        main.append(list);

        window.set_child(main);
        window.present();
    });

    var stat = app.run(argv);

    var outStr = "";

    todos.foreach((str) => {
        outStr += str + "\n";
    });

    outStr = outStr[0:outStr.length - 1];

    if (file.query_exists()) {
        file.delete();
    }

    try {
        var dos = new DataOutputStream(file.create(FileCreateFlags.REPLACE_DESTINATION));

        dos.write(outStr.data);
	} catch (Error e) {
		print ("Error: %s\n", e.message);
	}

    return stat;
}
