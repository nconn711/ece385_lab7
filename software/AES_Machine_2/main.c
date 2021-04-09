/************************************************************************
Lab 9 Nios Software

Dong Kai Wang, Fall 2017
Christine Chen, Fall 2013

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "system.h"
#include "aes.h"

// Pointer to base address of AES module, make sure it matches Qsys
volatile unsigned int * AES_PTR = (unsigned int *)AES_DECRYPTION_CORE_0_BASE;

// Execution mode: 0 for testing, 1 for benchmarking
int run_mode = 0;

/** charToHex
 *  Convert a single character to the 4-bit value it represents.
 *  
 *  Input: a character c (e.g. 'A')
 *  Output: converted 4-bit value (e.g. 0xA)
 *
 */
char charToHex(char c)
{
	char hex = c;

	if (hex >= '0' && hex <= '9')
		hex -= '0';
	else if (hex >= 'A' && hex <= 'F')
	{
		hex -= 'A';
		hex += 10;
	}
	else if (hex >= 'a' && hex <= 'f')
	{
		hex -= 'a';
		hex += 10;
	}
	return hex;
}

/** charsToHex
 *  Convert two characters to byte value it represents.
 *  Inputs must be 0-9, A-F, or a-f.
 *  
 *  Input: two characters c1 and c2 (e.g. 'A' and '7')
 *  Output: converted byte value (e.g. 0xA7)
 */
char charsToHex(char c1, char c2)
{
	char hex1 = charToHex(c1);
	char hex2 = charToHex(c2);
	return (hex1 << 4) + hex2;
}

void charArrayToHex(unsigned char *char_array, unsigned char *hex_array) {
	for (int row = 0; row < 4; row++) {
		for (int col = 0; col < 4; col++) {
			int index = (row + col * 4) * 2;
			hex_array[col+row*4] = charsToHex(char_array[index], char_array[index + 1]);
		}
	}
}

void hexArrayToInt(unsigned char *hex_array, unsigned int *int_array) {
	for (int word = 0; word < 4; word++) {
		int_array[word] = (hex_array[word+0*4] << 8*3) | (hex_array[word+1*4] << 8*2) | (hex_array[word+2*4] << 8*1) | (hex_array[word+3*4] << 8*0);
	}
}

void rotWord(unsigned char *key, unsigned char *round_key, int z) {
	if (z == 0) {
		for (int row = 0; row < 4; row++) {
			round_key[0+row*4+0*16] = key[3+((row+1)%4)*4];
		}
	}
	else {
		for (int row = 0; row < 4; row++) {
			round_key[0+row*4+z*16] = round_key[3+((row+1)%4)*4+(z-1)*16];
		}
	}
}

void subWord(unsigned char *round_key, int z) {
	for (int row = 0; row < 4; row++) {
		round_key[0+row*4+z*16] = aes_sbox[round_key[0+row*4+z*16]];
	}
}

void xorRcon(unsigned char *key, unsigned char *round_key, int z) {
	if (z == 0) {
		for (int row = 0; row < 4; row++) {
			round_key[0+row*4+0*16] = key[0+row*4] ^ round_key[0+row*4+0*16] ^ ((Rcon[1] & (0xff << ((3 - row)*8))) >> ((3 - row)*8));
		}
	}
	else {
		for (int row = 0; row < 4; row++) {
			round_key[0+row*4+z*16] = round_key[0+row*4+(z-1)*16] ^ round_key[0+row*4+z*16] ^ ((Rcon[z+1] & (0xff << ((3 - row)*8))) >> ((3 - row)*8));
		}
	}
}

void xor(unsigned char *key, unsigned char *round_key, int z) {
	if (z == 0) {
		for (int col = 1; col < 4; col++) {
			for (int row = 0; row < 4; row++) {
				round_key[col+row*4+0*16] = key[col+row*4] ^ round_key[(col-1)+row*4+0*16];
			}
		}
	}
	else {
		for (int col = 1; col < 4; col++) {
			for (int row = 0; row < 4; row++) {
				round_key[col+row*4+z*16] = round_key[col+row*4+(z-1)*16] ^ round_key[(col-1)+row*4+z*16];
			}
		}
	}
}

void keyExpansion(unsigned char *key, unsigned char *round_key) {
	for (int z = 0; z < 10; z++) {
		rotWord(key, round_key, z);
		subWord(round_key, z);
		xorRcon(key, round_key, z);
		xor(key, round_key, z);
	}
}

void subBytes(unsigned char *state) {
	for (int row = 0; row < 4; row++) {
		for (int col = 0; col < 4; col++) {
			state[col+row*4] = aes_sbox[state[col+row*4]];
		}
	}
}

void shiftRows(unsigned char *state) {
	unsigned char prestate[4][4];
	for (int row = 0; row < 4; row++) {
		for (int col = 0; col < 4; col++) {
			prestate[row][col] = state[col+row*4];
		}
	}
	for (int row = 1; row < 4; row++) {
		for (int col = 0; col < 4; col++) {
			state[col+row*4] = prestate[row][(col+row)%4];
		}
	}
}

void mixColumns(unsigned char *state) {
	unsigned char prestate[4][4];
	for (int row = 0; row < 4; row++) {
		for (int col = 0; col < 4; col++) {
			prestate[row][col] = state[col+row*4];
		}
	}
	for (int col = 0; col < 4; col++) {
		state[col+0*4] = gf_mul[prestate[0][col]][0] ^ gf_mul[prestate[1][col]][1] ^ prestate[2][col] ^ prestate[3][col];
	}
	for (int col = 0; col < 4; col++) {
		state[col+1*4] = prestate[0][col] ^ gf_mul[prestate[1][col]][0] ^ gf_mul[prestate[2][col]][1] ^ prestate[3][col];
	}
	for (int col = 0; col < 4; col++) {
		state[col+2*4] = prestate[0][col] ^ prestate[1][col] ^ gf_mul[prestate[2][col]][0] ^ gf_mul[prestate[3][col]][1];
	}
	for (int col = 0; col < 4; col++) {
		state[col+3*4] = gf_mul[prestate[0][col]][1] ^ prestate[1][col] ^ prestate[2][col] ^ gf_mul[prestate[3][col]][0];
	}
}

void addRoundKey(unsigned char *state, unsigned char *round_key) {
	for (int row = 0; row < 4; row++) {
		for (int col = 0; col < 4; col++) {
			int index = (col + row * 4) * 2;
			state[col+row*4] = state[col+row*4] ^ round_key[col+row*4];
		}
	}
}

/** encrypt
 *  Perform AES encryption in software.
 *
 *  Input: msg_ascii - Pointer to 32x 8-bit char array that contains the input message in ASCII format
 *         key_ascii - Pointer to 32x 8-bit char array that contains the input key in ASCII format
 *  Output:  msg_enc - Pointer to 4x 32-bit int array that contains the encrypted message
 *               key - Pointer to 4x 32-bit int array that contains the input key
 */
void encrypt(unsigned char * msg_ascii, unsigned char * key_ascii, unsigned int * msg_enc, unsigned int * key)
{

	// convert ms_ascii to hex matrix
	unsigned char state[4][4];
	unsigned char key_[4][4];
	unsigned char round_key[10][4][4];
	
	charArrayToHex(msg_ascii, state);
	charArrayToHex(key_ascii, key_);
	keyExpansion(key_, round_key);

	addRoundKey(state, key_);
	for (int round = 0; round < 9; round++) {
		subBytes(state);
		shiftRows(state);
		mixColumns(state);
		addRoundKey(state, round_key[round]);
	}
	subBytes(state);
	shiftRows(state);
	addRoundKey(state, round_key[9]);

	hexArrayToInt(state, msg_enc);
	hexArrayToInt(key_, key);
}

/** decrypt
 *  Perform AES decryption in hardware.
 *
 *  Input:  msg_enc - Pointer to 4x 32-bit int array that contains the encrypted message
 *              key - Pointer to 4x 32-bit int array that contains the input key
 *  Output: msg_dec - Pointer to 4x 32-bit int array that contains the decrypted message
 */
void decrypt(unsigned int * msg_enc, unsigned int * msg_dec, unsigned int * key)
{
	for(int i = 0; i < 4; i++){
		*(AES_PTR + i) = key[i];
		*(AES_PTR + i + 4) = msg_enc[i];
	}
	*(AES_PTR + 14) = 0x1;
	printf("%032x", *(AES_PTR + 14));
	while (!(*(AES_PTR + 15) && 0x1));
	for(int i = 0; i < 4; i++){
		msg_dec[i] = *(AES_PTR + i + 8);
	}
	*(AES_PTR + 14) = 0x0;
}

/** main
 *  Allows the user to enter the message, key, and select execution mode
 *
 */
int main()
{
	// Input Message and Key as 32x 8-bit ASCII Characters ([33] is for NULL terminator)
	unsigned char msg_ascii[33];
	unsigned char key_ascii[33];
	// Key, Encrypted Message, and Decrypted Message in 4x 32-bit Format to facilitate Read/Write to Hardware
	unsigned int key[4];
	unsigned int msg_enc[4];
	unsigned int msg_dec[4];

	printf("Select execution mode: 0 for testing, 1 for benchmarking: ");
	scanf("%d", &run_mode);

	if (run_mode == 0) {
		// Continuously Perform Encryption and Decryption
		while (1) {
			int i = 0;
			printf("\nEnter Message:\n");
			scanf("%s", msg_ascii);
			printf("\n");
			printf("\nEnter Key:\n");
			scanf("%s", key_ascii);
			printf("\n");
			encrypt(msg_ascii, key_ascii, msg_enc, key);
			printf("\nEncrpted message is: \n");
			for(i = 0; i < 4; i++){
				printf("%08x", msg_enc[i]);
			}
			printf("\n");
			decrypt(msg_enc, msg_dec, key);
			printf("\nDecrypted message is: \n");
			for(i = 0; i < 4; i++){
				printf("%08x", msg_dec[i]);
			}
			printf("\n");
		}
	}
	else {
		// Run the Benchmark
		int i = 0;
		int size_KB = 2;
		// Choose a random Plaintext and Key
		for (i = 0; i < 32; i++) {
			msg_ascii[i] = 'a';
			key_ascii[i] = 'b';
		}
		// Run Encryption
		clock_t begin = clock();
		for (i = 0; i < size_KB * 64; i++)
			encrypt(msg_ascii, key_ascii, msg_enc, key);
		clock_t end = clock();
		double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
		double speed = size_KB / time_spent;
		printf("Software Encryption Speed: %f KB/s \n", speed);
		// Run Decryption
		begin = clock();
		for (i = 0; i < size_KB * 64; i++)
			decrypt(msg_enc, msg_dec, key);
		end = clock();
		time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
		speed = size_KB / time_spent;
		printf("Hardware Encryption Speed: %f KB/s \n", speed);
	}
	return 0;
}
