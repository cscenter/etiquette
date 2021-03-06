glib=`pkg-config --cflags glib-2.0`
gdk=`pkg-config --cflags gdk-pixbuf-2.0`
notify=`pkg-config --cflags --libs libnotify`
vmime=`pkg-config --cflags --libs vmime`
python=-I/usr/include/python2.7/ -lpython2.7
tinyxml=-ltinyxml
lib_test=-lgtest -lpthread -I /usr/gtest/include -lgtest_main
comflag=-std=c++11 -c -g -fPIC

all: bin icon bin/accounts.so bin/applet.py bin/main.py bin/server.py bin/MailDB.py bin/FilterMessages.py bin/config.xml

valgrind: bin test
	valgrind --leak-check=full -v --log-file="valgrind.log" ./bin/test

testrun: test all testcpp testpy

testcpp:
	valgrind --leak-check=full -v --log-file="valgrind.log" ./bin/test
testpy: bin/TestFilterMessages.py all 
	python -m pytest -q ./bin/TestFilterMessages.py
	
test: bin bin/test

bin/accounts.so: bin/MailBoxSetting.o bin/certificateVerifier.o bin/NotifyMessage.o bin/Message.o bin/MailBox.o bin/Setting.o bin/Accounts.o bin/Accounts_Py.o
	g++ -std=c++11 -shared $^ $(tinyxml) $(python) $(vmime) $(notify) -lboost_python -o $@

bin/test: bin/MailBoxSetting.o bin/certificateVerifier.o bin/NotifyMessage.o bin/Message.o bin/MailBox.o bin/Setting.o bin/Accounts.o bin/test.o
	g++ -std=c++11 -g $^ $(tinyxml) $(python) $(vmime) $(notify) $(lib_test) -o $@

bin/test.o: test/test.cpp src/net/MailBox.hpp src/net/MailBoxSetting.hpp
	g++ -std=c++11 -c -g $(LIB_TEST) test/test.cpp -o $@

bin/Accounts_Py.o: src/net/Setting.hpp src/net/Setting.cpp src/net/Accounts_Py.cpp
	g++ $(comflag) src/net/Accounts_Py.cpp -I /usr/include/python2.7/ -lboost_python -o $@

bin/Accounts.o: src/net/Accounts.hpp src/net/Accounts.cpp src/net/Setting.hpp
	g++ $(comflag) src/net/Accounts.cpp -o $@

bin/Setting.o: src/net/Setting.hpp src/net/Setting.cpp
	g++ $(comflag) src/net/Setting.cpp -o $@

bin/MailBox.o: src/net/MailBox.cpp src/net/timeoutHandler.hpp src/net/Message.hpp src/net/MailBoxSetting.hpp src/net/certificateVerifier.hpp
	g++ $(comflag) src/net/MailBox.cpp -o $@

bin/Message.o: src/net/Message.cpp src/net/Message.hpp
	g++ $(comflag) src/net/Message.cpp -o $@

bin/NotifyMessage.o: src/net/Message.hpp src/ui/cpp/NotifyMessage.cpp src/ui/cpp/NotifyMessage.hpp
	g++ $(comflag) $(glib) $(gdk) src/ui/cpp/NotifyMessage.cpp -o $@

bin/certificateVerifier.o: src/net/certificateVerifier.cpp src/net/certificateVerifier.hpp
	g++ $(comflag) src/net/certificateVerifier.cpp -o $@

bin/MailBoxSetting.o: src/net/MailBoxSetting.cpp src/net/MailBoxSetting.hpp
	g++ $(comflag) src/net/MailBoxSetting.cpp -o $@

bin/messagesmodule.o: src/net/messagesmodule.c src/ui/cpp/NotifyMessage.hpp src/net/Message.hpp
	g++ $(comflag) $(python) src/net/messagesmodule.c -o $@


bin/FilterMessages.py: src/db/FilterMessages.py
	cp ./src/db/FilterMessages.py bin/
bin/applet.py: src/ui/py/applet.py
	cp ./src/ui/py/applet.py bin/
bin/main.py: src/main.py
	cp ./src/main.py bin/
bin/server.py: src/net/server.py
	cp ./src/net/server.py bin/
bin/MailDB.py: src/db/MailDB.py
	cp ./src/db/MailDB.py bin/
bin/config.xml: config.xml
	cp ./config.xml bin/
bin:
	mkdir -p bin/icons
icon:
	cp -r ./icons/* bin/icons

bin/TestFilterMessages.py: test/TestFilterMessages.py
	cp ./test/TestFilterMessages.py bin/

clean:
	rm -rf ./bin
