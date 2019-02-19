#include <iostream>
#include <mdsobjects.h>

namespace mds = MDSplus;

int main(int argc, char *argv[])
{
    mds::Data *data = new mds::Int32(5552368);
    std::cout << mds::AutoString(data->getString())
              << " - Who u gonna call! " << "\n";
    mds::deleteData(data);
    return 0;
}
