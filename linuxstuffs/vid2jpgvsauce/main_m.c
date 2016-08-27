/* Simple PNGV Encoder by Rinnegatamante */
#include <stdio.h>
#include <dirent.h>
#include <string.h>
#include <stdlib.h>

int main(int argc,char** argv){
	FILE* output = fopen("output.jpgv", "w");
	fwrite("JPGV",1,4,output);
	DIR* temp = opendir("./temp");
	char* p;
	unsigned long width = 0;
	unsigned long height = 0;
	unsigned long framerate = atoi(argv[1]);
	unsigned long samplerate;
	unsigned short bytepersample;
	unsigned short audiotype;
	char* audio_buffer;
	unsigned short codec;
	unsigned long audiosize;
	struct dirent *file;
	int i = 1;
	unsigned long long offset;
	while (file = readdir(temp)){
		if (strcmp(file->d_name,"audio.wav") == 0){
			FILE* input_audio = fopen("./temp/audio.wav","r");
			fseek(input_audio, 22, SEEK_SET);
			fread(&audiotype, 2, 1, input_audio);
			fread(&samplerate, 2, 1, input_audio);
			codec = 0;
			fseek(input_audio, 32, SEEK_SET);
			fread(&bytepersample, 2, 1, input_audio);
			fseek(input_audio, 16, SEEK_SET);
			unsigned long chunk = 0;
			unsigned long jump = 0;
			while (chunk != 0x61746164){
				fread(&jump, 4, 1, input_audio);
				fseek(input_audio,jump,SEEK_CUR);
				fread(&chunk, 4, 1, input_audio);
			}
			unsigned long read_start = (unsigned long)ftell(input_audio) + 4;
			fseek(input_audio, 0, SEEK_END);
			unsigned long size = (unsigned long)ftell(input_audio);
			audiosize = size - read_start;
			audio_buffer = (char*)malloc(audiosize);
			fseek(input_audio, read_start, SEEK_SET);
			fread(audio_buffer, 1, audiosize, input_audio);
			fclose(input_audio);
		}else if (strcmp(file->d_name,"audio.ogg") == 0){
			audiotype = 0x0000;
			codec = 1;
			samplerate = 0x0000;
			bytepersample = 0x0000;
			FILE* input_audio = fopen("./temp/audio.ogg","r");		
			unsigned long read_start = 0;
			fseek(input_audio, 0, SEEK_END);
			unsigned long size = (unsigned long)ftell(input_audio);
			audiosize = size - read_start;
			audio_buffer = (char*)malloc(audiosize);
			fseek(input_audio, read_start, SEEK_SET);
			fread(audio_buffer, 1, audiosize, input_audio);
			fclose(input_audio);
		}else if (strcmp(file->d_name,".") == 0) continue;
		else if (strcmp(file->d_name,"..") == 0) continue;
		else{
			char filename[256];
			sprintf(filename, "./temp/output%d.jpg", i);
			i++;
			FILE* input_frame = fopen(filename,"r");
			if (width == 0){
				width = 0xFFFFFFFF;
				fwrite(&framerate, 4, 1, output);
				fwrite(&audiotype, 2, 1, output);
				fwrite(&bytepersample, 2, 1, output);
				fwrite(&samplerate, 2, 1, output);
				fwrite(&codec, 2, 1, output);
				fwrite(&samplerate,4,1,output); //Fake
				fwrite(&audiosize, 4, 1, output);
				offset = audiosize + 24;
				fwrite(audio_buffer, 1, audiosize, output);
				free(audio_buffer);
			}
			fwrite(&offset, 8, 1, output);
			fseek(input_frame, 0, SEEK_END);
			unsigned long long size_frame = (unsigned long long)ftell(input_frame);
			offset = offset + size_frame;
			fclose(input_frame);
		}
		}
		closedir(temp);
		temp = opendir("./temp");
		unsigned long off = ftell(output);
		fseek(output,0x10,SEEK_SET);
		i--;
		fwrite(&i,4, 1, output);
		fseek(output,off,SEEK_SET);
		i = 1;
		while (file = readdir(temp)){
		if (strcmp(file->d_name,"audio.wav") == 0) continue;
		else if (strcmp(file->d_name,"audio.ogg") == 0) continue;
		else if (strcmp(file->d_name,".") == 0) continue;
		else if (strcmp(file->d_name,"..") == 0) continue;
		else{
			char filename[256];
			sprintf(filename, "./temp/output%d.jpg", i);
			i++;
			FILE* input_frame = fopen(filename,"r");
			fseek(input_frame, 0, SEEK_END);
			unsigned long long size_frame = (unsigned long long)ftell(input_frame);
			char* buffer = (char*)malloc(size_frame);
			fseek(input_frame,0,SEEK_SET);
			fread(buffer, 1, size_frame, input_frame);
			fclose(input_frame);
			fwrite(buffer,1, size_frame, output);
			free(buffer);
		}
	}
	closedir(temp);
	fclose(output);
	return 0;
}