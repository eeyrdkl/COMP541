#include "tsdf_base.h"
extern "C"
{
	int calculateTSDF(int db, int maxscenes);
}

int initTSDFStuff()
{
	return 1;
}

int calculateTSDF(int db, int maxscenes)
{
	string file_list = "";
	if (db == 0)
		file_list = "..//data//boxes_NYU_po_test_nb2000_fb.list";
	else
		file_list = "..//data//boxes_SUNrgbd_po_test_nb2000_fb.list";

	string data_root =  "..//data//";
	string output_data = "..//data//julia_data//";

	std::vector<Scene3D*> scenes;
	std::vector<int> box_id;

	int totalObjectCount = 0;
	float scale =100;
	float context_pad =3;
	std::vector<int> grid_size {3,30,30,30};
	int encode_type =100;

	int totalScenes = 0;

	std::cout<<"loading file "<<file_list<< endl << endl;
	FILE* fp = fopen(file_list.c_str(),"rb");
	if (fp==NULL) { std::cout<<"fail to open file: "<<file_list<<std::endl; exit(EXIT_FAILURE); }
	while (feof(fp)==0 && totalScenes < maxscenes) 
	{

		Scene3D* scene = new Scene3D();
		unsigned int len = 0;
		fread((void*)(&len), sizeof(unsigned int), 1, fp);    
		if (len==0) break;
		scene->filename.resize(len);
		if (len>0) fread((void*)(scene->filename.data()), sizeof(char), len, fp);

		//TSDF file
		int lastback = scene->filename.find_last_of("/");
		string outputname = "";
		if (lastback > 0)
		{
			outputname = scene->filename.substr(lastback+1);
		}
		else
		{
			FatalError(__LINE__);
			continue;
		}
		scene->filename = data_root+scene->filename+".bin"; 
		string tsdffile = output_data+outputname+".tsdf";


		fread((void*)(scene->R), sizeof(float), 9, fp);
		fread((void*)(scene->K), sizeof(float), 9, fp);
		fread((void*)(&scene->height), sizeof(unsigned int), 1, fp);  
		fread((void*)(&scene->width), sizeof(unsigned int), 1, fp); 


		fread((void*)(&len),    sizeof(unsigned int),   1, fp);
		scene->objects.resize(len);
		if (len>0){
		  totalObjectCount += len;
		  for (int i=0;i<len;++i){
		      Box3D box;
		      fread((void*)(&(box.category)), sizeof(unsigned int),   1, fp);
		      fread((void*)(box.base),        sizeof(float), 9, fp);
		      fread((void*)(box.center),      sizeof(float), 3, fp);
		      fread((void*)(box.coeff),       sizeof(float), 3, fp);
		      //process box pad contex oreintation 
		      box = processbox (box, context_pad, grid_size[1]);
		      scene->objects[i]=box;
		      box_id.push_back(i);
		  }
		}
		scenes.push_back(scene);
		totalScenes++;

		cout << "Scene: " << totalScenes << " Boxes: " << len << " Bin: " << scene->filename << " TSDF: " << tsdffile << endl << endl;

		unsigned long long  time0,time1;

		time0 = get_timestamp_dss();
		float* dataCPUmem = new float[(len)*3*30*30*30];
		StorageT* dataGPUmem;
		checkCUDA(__LINE__, cudaMalloc(&dataGPUmem, (len)*3*30*30*30*sizeof(float)));
		time1 = get_timestamp_dss();
		cout << "cpu->gpu time " << (time1-time0)/1000 << " ms" << endl;

		time0 = get_timestamp_dss();
		compute_TSDF(&scenes, &box_id, dataGPUmem,grid_size,encode_type,scale);
		time1 = get_timestamp_dss();
		cout << "compute time " << (time1-time0)/1000 << " ms" << endl;

		time0 = get_timestamp_dss();
		checkCUDA(__LINE__, cudaMemcpy(dataCPUmem, dataGPUmem,(len)*3*30*30*30*sizeof(float), cudaMemcpyDeviceToHost) );
		time1 = get_timestamp_dss();
		cout << "gpu->cpu time " << (time1-time0)/1000 << " ms" << endl;

		//clear for workaround
		scenes.clear();
		box_id.clear();

		//can print these or not
		//totalScenes
		//totalObjectCount

		time0 = get_timestamp_dss();
		FILE * fid = fopen(tsdffile.c_str(),"wb");
		fwrite(dataCPUmem,sizeof(float),(len)*3*30*30*30,fid);
		fclose(fid);
		time1 = get_timestamp_dss();
		cout << "cpu->file " << (time1-time0)/1000 << " ms" << endl << endl;
	
		//free
		delete scene;
		delete[] dataCPUmem;
		cudaFree(dataGPUmem);
	}
	fclose(fp);
	return 42;
}
int main(){
	return 1;
}
