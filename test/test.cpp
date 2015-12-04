#include <vmime/platforms/posix/posixHandler.hpp> 
#include "../src/net/MailBox.hpp"
#include "../src/net/MailBoxSetting.hpp"
#include <gtest/gtest.h>


class MailBoxTest : public ::testing::Test {
    protected:

    MailBoxTest() {
        //1
        vmime::platform::setHandler<vmime::platforms::posix::posixHandler>();
        MailBoxSetting setting_1("test.imap2015@mail.ru", "824222443a", "imap.mail.ru:993");
        MailBox mailbox1(setting_1);
        mailbox1_ = mailbox1;
        
        MailBoxSetting setting_2("test.imap2016@mail.ru", "2345fg123", "imap.mail.ru:993");
        MailBox mailbox2(setting_2);
        mailbox2_ = mailbox2;
    }

    MailBox mailbox1_;
    MailBox mailbox2_;
};

TEST_F(MailBoxTest, getUnAnswered) {
    mailbox1_.connect();
    EXPECT_EQ(5, mailbox1_.getUnAnswered().size());
    mailbox2_.connect();
    EXPECT_EQ(1, mailbox2_.getUnAnswered().size());
    EXPECT_EQ("welcome@corp.mail.ru", mailbox2_.getUnAnswered()[0].getFrom());
}

TEST_F(MailBoxTest, getLogin) {
    mailbox1_.connect();
    EXPECT_EQ("test.imap2015@mail.ru", mailbox1_.getLogin());
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
