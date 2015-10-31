#include <iostream>
#include <string>
#include <vmime/vmime.hpp>

#include "MailBox.hpp"
#include "Message.hpp"
#include "NotifyMessage.hpp"


	

inline void eatline() { while (std::cin.get() != '\n') continue; }

int main(void)
{
	std::string login;
	std::string password;
	std::string server;
	
	std::cout << "Login:";
	std::cin >> login;
	eatline();
	std::cout << "Password:";
	std::cin >> password;
	eatline();
	std::cout << "Server:";
	std::cin >> server;
	eatline();


	MailBox mailbox(login, password, server);
	mailbox.connect();
	std::vector<Message> messages = mailbox.getUnAnswered();
	for(size_t i = 0; i < messages.size(); ++i)
	{
		Message msg = messages[i];
		NotifyMessage notifyMessage(msg);
		notifyMessage.printNotify();
	}

	return 0;	
}


