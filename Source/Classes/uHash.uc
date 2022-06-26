//////////////////////////////////////////////////////////////////////////////
// uHash - UScript hashing class
// Supported hash functions: MD5, SHA-1, SHA-224, SHA-256, SHA-384, SHA-512
//		Feralidragon - 29-06-2013
//////////////////////////////////////////////////////////////////////////////

class uHash extends Object 
abstract;

struct int64 {var int i1, i0;};	//Int x64

var const int K_MD5[64];
var const byte R_MD5[64];
var const string HEX_CHARS[16];

var const int K_SHA2XX[64];
var const int64 K_SHA5XX[80];


///////////////////////////////////////////////////////////////////////////////////////////////////////
// INTx86 and INTx64 functions and operators
static function int64 intx64(coerce int int32A, optional coerce int int32B)
{
local int64 i64;

	i64.i0 = int32A;
	i64.i1 = int32B;
	return i64;
}

static function int intx86(int64 i64)
{
	return i64.i0;
}

static final preoperator int64 ~ (int64 A)
{
	A.i1 = (~A.i1);
	A.i0 = (~A.i0);
	return A;
}

static final preoperator int64 - (int64 A)
{
	A = (~A);
	if (A.i0 == 0xFFFFFFFF)
	{
		A.i1++;
		A.i0 = 0;
		return A;
	}
	A.i0++;
	return A;
}

static final operator(20) int64 + (int64 A, int64 B)
{
local int64 i64;
local int n, cin, cout, bitA, bitB, bitS;

	for (n = 0; n < 32; n++)
	{
		cin = cout;
		bitA = ((A.i0 >>> n) & 0x00000001);
		bitB = ((B.i0 >>> n) & 0x00000001);
		bitS = (bitA ^ bitB);
		cout = ((bitA & bitB) | (cin & bitS));
		bitS = (bitS ^ cin);
		i64.i0 = (i64.i0 | (bitS << n));
	}
	
	i64.i1 = A.i1 + B.i1 + cout;
	return i64;
}

static final operator(20) int64 + (int64 A, coerce int B)
{
	return (A + intx64(B));
}

static final operator(20) int64 + (coerce int A, int64 B)
{
	return (intx64(A) + B);
}

static final operator(20) int64 - (int64 A, int64 B)
{
	return (A + (-B));
}

static final operator(20) int64 - (int64 A, coerce int B)
{
	return (A - intx64(B));
}

static final operator(20) int64 - (coerce int A, int64 B)
{
	return (intx64(A) - B);
}

static final operator(34) int64 += (out int64 A, int64 B)
{
	A = A + B;
	return A;
}

static final operator(34) int64 -= (out int64 A, int64 B)
{
	A = A - B;
	return A;
}

static final operator(22) int64 << (int64 A, coerce int B)
{
	if (B >= 32)
	{
		A.i1 = (A.i0 << (B-32));
		A.i0 = 0x00000000;
	}
	else if (B > 0)
	{
		A.i1 = ((A.i1 << B) | (A.i0 >>> (32-B)));
		A.i0 = (A.i0 << B);
	}
	return A;
}

static final operator(22) int64 >>> (int64 A, coerce int B)
{
	if (B >= 32)
	{
		A.i0 = (A.i1 >>> (B-32));
		A.i1 = 0x00000000;
	}
	else if (B > 0)
	{
		A.i0 = ((A.i0 >>> B) | (A.i1 << (32-B)));
		A.i1 = (A.i1 >>> B);
	}
	return A;
}

static final operator(28) int64 & (int64 A, int64 B)
{
local int64 i64;
	
	i64.i1 = (A.i1 & B.i1);
	i64.i0 = (A.i0 & B.i0);
	return i64;
}

static final operator(28) int64 ^ (int64 A, int64 B)
{
local int64 i64;
	
	i64.i1 = (A.i1 ^ B.i1);
	i64.i0 = (A.i0 ^ B.i0);
	return i64;
}

static final operator(28) int64 | (int64 A, int64 B)
{
local int64 i64;
	
	i64.i1 = (A.i1 | B.i1);
	i64.i0 = (A.i0 | B.i0);
	return i64;
}

static final operator(22) int leftrotate (coerce int n, coerce int bits_n)
{
	return ((n << bits_n) | (n >>> (32-bits_n)));
}

static final operator(22) int64 leftrotate (int64 n, coerce int bits_n)
{
	return ((n << bits_n) | (n >>> (64-bits_n)));
}

static final operator(22) int rightrotate (coerce int n, coerce int bits_n)
{
	return ((n >>> bits_n) | (n << (32-bits_n)));
}

static final operator(22) int64 rightrotate (int64 n, coerce int bits_n)
{
	return ((n >>> bits_n) | (n << (64-bits_n)));
}


//////////////////////////////////////////////////////////////////////////////
// Get MD5
simulated static function string MD5(string msg)
{
local byte cbyte[64], len64[8];
local int i, j, u;
local int w[16];
local int h0, h1, h2, h3;
local int msglen, tchars, lenbits;
local int A, B, C, D, F, g, dTemp;
local string submsg;
	
	//Init h values
	h0 = 0x67452301;
	h1 = 0xEFCDAB89;
	h2 = 0x98BADCFE;
	h3 = 0x10325476;
	
	//Pre-processing
	msglen = len(msg);
	tchars = (msglen + 9) + (64 - ((msglen + 9) % 64));
	lenbits = msglen*8;
	len64[3] = Byte((lenbits >>> 24) & 0x000000FF);
	len64[2] = Byte((lenbits >>> 16) & 0x000000FF);
	len64[1] = Byte((lenbits >>> 8) & 0x000000FF);
	len64[0] = Byte(lenbits & 0x000000FF);
	
	//Process each 512bit chunk
	for (i = 0; i < tchars; i += 64)
	{
		//Form 512bit array (as bytes)
		submsg = mid(msg, i, 64);
		for (j = 0; j < 64; j++)
		{
			u = i + j;
			if (u < msglen)
				cbyte[j] = asc(mid(submsg, j, 1));
			else if (u > msglen)
			{
				if (u < (tchars - 8))
					cbyte[j] = 0x00;
				else
					cbyte[j] = len64[j - 56];
			}
			else
				cbyte[j] = 0x80;
		}
		
		//Form 32bit words
		for (j = 0; j < 16; j++)
			w[j] = ((cbyte[j*4 + 3] << 24) | (cbyte[j*4 + 2] << 16) | (cbyte[j*4 + 1] << 8) | cbyte[j*4]);

		//Process rest of hash
		A = h0;
		B = h1;
		C = h2;
		D = h3;

		for (j = 0; j < 64; j++)
		{
			if (j < 16)
			{
				F = ((B & C) | ((~B) & D));
				g = j;
			}
			else if (j < 32)
			{
				F = ((D & B) | ((~D) & C));
				g = ((5*j + 1) % 16);
			}
			else if (j < 48)
			{
				F = (B ^ C ^ D);
				g = ((3*j + 5) % 16);
			}
			else
			{
				F = (C ^ (B | (~D)));
				g = ((7*j) % 16);
			}

			dTemp = D;
			D = C;
			C = B;
			B += ((A + F + default.K_MD5[j] + w[g]) leftrotate default.R_MD5[j]);
			A = dTemp;
		}

		h0 += A;
		h1 += B;
		h2 += C;
		h3 += D;
	}
	
	return (hexFromWord(h0, True) $ hexFromWord(h1, True) $ hexFromWord(h2, True) $ hexFromWord(h3, True));
}


//////////////////////////////////////////////////////////////////////////////
// Get SHA-1
simulated static function string SHA1(string msg)
{
local int h0, h1, h2, h3, h4;
local byte cbyte[64], len64[8];
local int i, j, u;
local int w[80];
local int msglen, tchars, lenbits;
local int a, b, c, d, e, f, k, temp;
local string submsg;

	//Init h values
	h0 = 0x67452301;
	h1 = 0xEFCDAB89;
	h2 = 0x98BADCFE;
	h3 = 0x10325476;
	h4 = 0xC3D2E1F0;
	
	//Pre-processing
	msglen = len(msg);
	tchars = (msglen + 9) + (64 - ((msglen + 9) % 64));
	lenbits = msglen*8;
	len64[4] = Byte((lenbits >>> 24) & 0x000000FF);
	len64[5] = Byte((lenbits >>> 16) & 0x000000FF);
	len64[6] = Byte((lenbits >>> 8) & 0x000000FF);
	len64[7] = Byte(lenbits & 0x000000FF);
	
	//Process each 512bit chunk
	for (i = 0; i < tchars; i += 64)
	{
		//Form 512bit array (as bytes)
		submsg = mid(msg, i, 64);
		for (j = 0; j < 64; j++)
		{
			u = i + j;
			if (u < msglen)
				cbyte[j] = asc(mid(submsg, j, 1));
			else if (u > msglen)
			{
				if (u < (tchars - 8))
					cbyte[j] = 0x00;
				else
					cbyte[j] = len64[j - 56];
			}
			else
				cbyte[j] = 0x80;
		}
		
		//Form 32bit words
		for (j = 0; j < 16; j++)
			w[j] = ((cbyte[j*4] << 24) | (cbyte[j*4 + 1] << 16) | (cbyte[j*4 + 2] << 8) | cbyte[j*4 + 3]);
			
		//Extend the sixteen 32-bit words into eighty 32-bit words
		for (j = 16; j < 80; j++)
			w[j] = ((w[j-3] ^ w[j-8] ^ w[j-14] ^ w[j-16]) leftrotate 1);
			
		//Calculate hash itself
		a = h0;
		b = h1;
		c = h2;
		d = h3;
		e = h4;
		
		for (j = 0; j < 80; j++)
		{
			if (j < 20)
			{
				f = ((b & c) | ((~b) & d));
				k = 0x5A827999;
			}
			else if (j < 40)
			{
				f = (b ^ c ^ d);
				k = 0x6ED9EBA1;
			}
			else if (j < 60)
			{
				f = ((b & c) | (b & d) | (c & d));
				k = 0x8F1BBCDC;
			}
			else
			{
				f = (b ^ c ^ d);
				k = 0xCA62C1D6;
			}
			
			temp = (a leftrotate 5) + f + e + k + w[j];
			e = d;
			d = c;
			c = (b leftrotate 30);
			b = a;
			a = temp;
		}
		
		h0 += a;
		h1 += b;
		h2 += c;
		h3 += d;
		h4 += e;
	}
	
	return (hexFromWord(h0) $ hexFromWord(h1) $ hexFromWord(h2) $ hexFromWord(h3) $ hexFromWord(h4));
}


//////////////////////////////////////////////////////////////////////////////
// Get SHA-2XX
simulated static function string SHA2XX(string msg, optional bool is224)
{
local int h0, h1, h2, h3, h4, h5, h6, h7;
local byte cbyte[64], len64[8];
local int i, j, u;
local int w[64];
local int msglen, tchars, lenbits;
local string submsg, hash;
local int s0, s1;
local int a, b, c, d, e, f, g, h;
local int ch, temp1, temp2, maj;


	//Init h values
	if (is224)
	{
		h0 = 0xc1059ed8;
		h1 = 0x367cd507;
		h2 = 0x3070dd17;
		h3 = 0xf70e5939;
		h4 = 0xffc00b31;
		h5 = 0x68581511;
		h6 = 0x64f98fa7;
		h7 = 0xbefa4fa4;
	}
	else
	{
		h0 = 0x6a09e667;
		h1 = 0xbb67ae85;
		h2 = 0x3c6ef372;
		h3 = 0xa54ff53a;
		h4 = 0x510e527f;
		h5 = 0x9b05688c;
		h6 = 0x1f83d9ab;
		h7 = 0x5be0cd19;
	}
	
	//Pre-processing
	msglen = len(msg);
	tchars = (msglen + 9) + (64 - ((msglen + 9) % 64));
	lenbits = msglen*8;
	len64[4] = Byte((lenbits >>> 24) & 0x000000FF);
	len64[5] = Byte((lenbits >>> 16) & 0x000000FF);
	len64[6] = Byte((lenbits >>> 8) & 0x000000FF);
	len64[7] = Byte(lenbits & 0x000000FF);
	
	//Process each 512bit chunk
	for (i = 0; i < tchars; i += 64)
	{
		//Form 512bit array (as bytes)
		submsg = mid(msg, i, 64);
		for (j = 0; j < 64; j++)
		{
			u = i + j;
			if (u < msglen)
				cbyte[j] = asc(mid(submsg, j, 1));
			else if (u > msglen)
			{
				if (u < (tchars - 8))
					cbyte[j] = 0x00;
				else
					cbyte[j] = len64[j - 56];
			}
			else
				cbyte[j] = 0x80;
		}
		
		//Form 32bit words
		for (j = 0; j < 16; j++)
			w[j] = ((cbyte[j*4] << 24) | (cbyte[j*4 + 1] << 16) | (cbyte[j*4 + 2] << 8) | cbyte[j*4 + 3]);
			
		//Extend the sixteen 32-bit words into 64 32-bit words
		for (j = 16; j < 64; j++)
		{
			s0 = ((w[j-15] rightrotate 7) ^ (w[j-15] rightrotate 18) ^ (w[j-15] >>> 3));
			s1 = ((w[j-2] rightrotate 17) ^ (w[j-2] rightrotate 19) ^ (w[j-2] >>> 10));
			w[j] = w[j-16] + s0 + w[j-7] + s1;
		}
			
		//Calculate hash itself
		a = h0;
		b = h1;
		c = h2;
		d = h3;
		e = h4;
		f = h5;
		g = h6;
		h = h7;
		
		for (j = 0; j < 64; j++)
		{
			s1 = ((e rightrotate 6) ^ (e rightrotate 11) ^ (e rightrotate 25));
			ch = ((e & f) ^ ((~e) & g));
			temp1 = h + s1 + ch + default.K_SHA2XX[j] + w[j];
			s0 = ((a rightrotate 2) ^ (a rightrotate 13) ^ (a rightrotate 22));
			maj = ((a & b) ^ (a & c) ^ (b & c));
			temp2 = s0 + maj;
			
			h = g;
			g = f;
			f = e;
			e = d + temp1;
			d = c;
			c = b;
			b = a;
			a = temp1 + temp2;
		}
		
		h0 += a;
		h1 += b;
		h2 += c;
		h3 += d;
		h4 += e;
		h5 += f;
		h6 += g;
		h7 += h;
	}
	
	hash = hexFromWord(h0) $ hexFromWord(h1) $ hexFromWord(h2) $ hexFromWord(h3) $ hexFromWord(h4) $ hexFromWord(h5) $ hexFromWord(h6);
	if (is224)
		return hash;
	return (hash $ hexFromWord(h7));
}

simulated static function string SHA224(string msg)
{
	return SHA2XX(msg, True);
}

simulated static function string SHA256(string msg)
{
	return SHA2XX(msg);
}


//////////////////////////////////////////////////////////////////////////////
// Get SHA-5XX
simulated static function string SHA5XX(string msg, optional bool is384)
{
local int64 h0, h1, h2, h3, h4, h5, h6, h7;
local byte cbyte[128], len128[16];
local int i, j, u;
local int64 w[80];
local int msglen, tchars, lenbits;
local string submsg, hash;
local int64 s0, s1;
local int64 a, b, c, d, e, f, g, h;
local int64 ch, temp1, temp2, maj;


	//Init h values
	if (is384)
	{
		h0 = intx64(0xc1059ed8, 0xcbbb9d5d);
		h1 = intx64(0x367cd507, 0x629a292a);
		h2 = intx64(0x3070dd17, 0x9159015a);
		h3 = intx64(0xf70e5939, 0x152fecd8);
		h4 = intx64(0xffc00b31, 0x67332667);
		h5 = intx64(0x68581511, 0x8eb44a87);
		h6 = intx64(0x64f98fa7, 0xdb0c2e0d);
		h7 = intx64(0xbefa4fa4, 0x47b5481d);
	}
	else
	{
		h0 = intx64(0xf3bcc908, 0x6a09e667);
		h1 = intx64(0x84caa73b, 0xbb67ae85);
		h2 = intx64(0xfe94f82b, 0x3c6ef372);
		h3 = intx64(0x5f1d36f1, 0xa54ff53a);
		h4 = intx64(0xade682d1, 0x510e527f);
		h5 = intx64(0x2b3e6c1f, 0x9b05688c);
		h6 = intx64(0xfb41bd6b, 0x1f83d9ab);
		h7 = intx64(0x137e2179, 0x5be0cd19);
	}
	
	//Pre-processing
	msglen = len(msg);
	tchars = (msglen + 17) + (128 - ((msglen + 17) % 128));
	lenbits = msglen*8;
	len128[12] = Byte((lenbits >>> 24) & 0x000000FF);
	len128[13] = Byte((lenbits >>> 16) & 0x000000FF);
	len128[14] = Byte((lenbits >>> 8) & 0x000000FF);
	len128[15] = Byte(lenbits & 0x000000FF);
	
	//Process each 1024bit chunk
	for (i = 0; i < tchars; i += 128)
	{
		//Form 1024bit array (as bytes)
		submsg = mid(msg, i, 128);
		for (j = 0; j < 128; j++)
		{
			u = i + j;
			if (u < msglen)
				cbyte[j] = asc(mid(submsg, j, 1));
			else if (u > msglen)
			{
				if (u < (tchars - 16))
					cbyte[j] = 0x00;
				else
					cbyte[j] = len128[j - 112];
			}
			else
				cbyte[j] = 0x80;
		}
		
		//Form 64bit words
		for (j = 0; j < 16; j++)
			w[j] = intx64((cbyte[j*8 + 4] << 24) | (cbyte[j*8 + 5] << 16) | (cbyte[j*8 + 6] << 8) | cbyte[j*8 + 7], 
			(cbyte[j*8] << 24) | (cbyte[j*8 + 1] << 16) | (cbyte[j*8 + 2] << 8) | cbyte[j*8 + 3]);
			
		//Extend the sixteen 64-bit words into 80 64-bit words
		for (j = 16; j < 80; j++)
		{
			s0 = ((w[j-15] rightrotate 1) ^ (w[j-15] rightrotate 8) ^ (w[j-15] >>> 7));
			s1 = ((w[j-2] rightrotate 19) ^ (w[j-2] rightrotate 61) ^ (w[j-2] >>> 6));
			w[j] = w[j-16] + s0 + w[j-7] + s1;
		}
			
		//Calculate hash itself
		a = h0;
		b = h1;
		c = h2;
		d = h3;
		e = h4;
		f = h5;
		g = h6;
		h = h7;
		
		for (j = 0; j < 80; j++)
		{
			s1 = ((e rightrotate 14) ^ (e rightrotate 18) ^ (e rightrotate 41));
			ch = ((e & f) ^ ((~e) & g));
			temp1 = h + s1 + ch + default.K_SHA5XX[j] + w[j];
			s0 = ((a rightrotate 28) ^ (a rightrotate 34) ^ (a rightrotate 39));
			maj = ((a & b) ^ (a & c) ^ (b & c));
			temp2 = s0 + maj;
			
			h = g;
			g = f;
			f = e;
			e = d + temp1;
			d = c;
			c = b;
			b = a;
			a = temp1 + temp2;
		}
		
		h0 += a;
		h1 += b;
		h2 += c;
		h3 += d;
		h4 += e;
		h5 += f;
		h6 += g;
		h7 += h;
	}
	
	hash = hexFromDWord(h0) $ hexFromDWord(h1) $ hexFromDWord(h2) $ hexFromDWord(h3) $ hexFromDWord(h4) $ hexFromDWord(h5);
	if (is384)
		return hash;
	return (hash $ hexFromDWord(h6) $ hexFromDWord(h7));
}

simulated static function string SHA384(string msg)
{
	return SHA5XX(msg, True);
}

simulated static function string SHA512(string msg)
{
	return SHA5XX(msg);
}



///////////////////////////////////////////////////////////////////////////////////////////////////////7
// Bytes to human-readable hex functions
simulated static function string hexFromWord(int x, optional bool isLEndian)
{
local string w;
local int a, i;

	for (i = 0; i < 4; i++)
	{
		if (isLEndian)
			a = i;
		else
			a = (3 - i);
		a = ((x >>> (a*8)) & 0x000000FF);
		w = w $ default.HEX_CHARS[(a & 0xF0) >>> 4] $ default.HEX_CHARS[a & 0x0F];
	}
	return w;
}

simulated static function string hexFromDWord(int64 x, optional bool isLEndian)
{
local string w;
local int i, a;

	for (i = 0; i < 8; i++)
	{
		if (isLEndian)
			a = i;
		else
			a = (7 - i);
		a = (intx86(x >>> (a*8)) & 0x000000FF);
		w = w $ default.HEX_CHARS[(a & 0xF0) >>> 4] $ default.HEX_CHARS[a & 0x0F];
	}
	return w;
}


defaultproperties
{
	HEX_CHARS(0)="0"
	HEX_CHARS(1)="1"
	HEX_CHARS(2)="2"
	HEX_CHARS(3)="3"
	HEX_CHARS(4)="4"
	HEX_CHARS(5)="5"
	HEX_CHARS(6)="6"
	HEX_CHARS(7)="7"
	HEX_CHARS(8)="8"
	HEX_CHARS(9)="9"
	HEX_CHARS(10)="a"
	HEX_CHARS(11)="b"
	HEX_CHARS(12)="c"
	HEX_CHARS(13)="d"
	HEX_CHARS(14)="e"
	HEX_CHARS(15)="f"
	
	K_MD5(0)=-680876936
	K_MD5(1)=-389564586
	K_MD5(2)=606105819
	K_MD5(3)=-1044525330
	K_MD5(4)=-176418897
	K_MD5(5)=1200080426
	K_MD5(6)=-1473231341
	K_MD5(7)=-45705983
	K_MD5(8)=1770035416
	K_MD5(9)=-1958414417
	K_MD5(10)=-42063
	K_MD5(11)=-1990404162
	K_MD5(12)=1804603682
	K_MD5(13)=-40341101
	K_MD5(14)=-1502002290
	K_MD5(15)=1236535329
	K_MD5(16)=-165796510
	K_MD5(17)=-1069501632
	K_MD5(18)=643717713
	K_MD5(19)=-373897302
	K_MD5(20)=-701558691
	K_MD5(21)=38016083
	K_MD5(22)=-660478335
	K_MD5(23)=-405537848
	K_MD5(24)=568446438
	K_MD5(25)=-1019803690
	K_MD5(26)=-187363961
	K_MD5(27)=1163531501
	K_MD5(28)=-1444681467
	K_MD5(29)=-51403784
	K_MD5(30)=1735328473
	K_MD5(31)=-1926607734
	K_MD5(32)=-378558
	K_MD5(33)=-2022574463
	K_MD5(34)=1839030562
	K_MD5(35)=-35309556
	K_MD5(36)=-1530992060
	K_MD5(37)=1272893353
	K_MD5(38)=-155497632
	K_MD5(39)=-1094730640
	K_MD5(40)=681279174
	K_MD5(41)=-358537222
	K_MD5(42)=-722521979
	K_MD5(43)=76029189
	K_MD5(44)=-640364487
	K_MD5(45)=-421815835
	K_MD5(46)=530742520
	K_MD5(47)=-995338651
	K_MD5(48)=-198630844
	K_MD5(49)=1126891415
	K_MD5(50)=-1416354905
	K_MD5(51)=-57434055
	K_MD5(52)=1700485571
	K_MD5(53)=-1894986606
	K_MD5(54)=-1051523
	K_MD5(55)=-2054922799
	K_MD5(56)=1873313359
	K_MD5(57)=-30611744
	K_MD5(58)=-1560198380
	K_MD5(59)=1309151649
	K_MD5(60)=-145523070
	K_MD5(61)=-1120210379
	K_MD5(62)=718787259
	K_MD5(63)=-343485551
	
	R_MD5(0)=7
	R_MD5(1)=12
	R_MD5(2)=17
	R_MD5(3)=22
	R_MD5(4)=7
	R_MD5(5)=12
	R_MD5(6)=17
	R_MD5(7)=22
	R_MD5(8)=7
	R_MD5(9)=12
	R_MD5(10)=17
	R_MD5(11)=22
	R_MD5(12)=7
	R_MD5(13)=12
	R_MD5(14)=17
	R_MD5(15)=22
	R_MD5(16)=5
	R_MD5(17)=9
	R_MD5(18)=14
	R_MD5(19)=20
	R_MD5(20)=5
	R_MD5(21)=9
	R_MD5(22)=14
	R_MD5(23)=20
	R_MD5(24)=5
	R_MD5(25)=9
	R_MD5(26)=14
	R_MD5(27)=20
	R_MD5(28)=5
	R_MD5(29)=9
	R_MD5(30)=14
	R_MD5(31)=20
	R_MD5(32)=4
	R_MD5(33)=11
	R_MD5(34)=16
	R_MD5(35)=23
	R_MD5(36)=4
	R_MD5(37)=11
	R_MD5(38)=16
	R_MD5(39)=23
	R_MD5(40)=4
	R_MD5(41)=11
	R_MD5(42)=16
	R_MD5(43)=23
	R_MD5(44)=4
	R_MD5(45)=11
	R_MD5(46)=16
	R_MD5(47)=23
	R_MD5(48)=6
	R_MD5(49)=10
	R_MD5(50)=15
	R_MD5(51)=21
	R_MD5(52)=6
	R_MD5(53)=10
	R_MD5(54)=15
	R_MD5(55)=21
	R_MD5(56)=6
	R_MD5(57)=10
	R_MD5(58)=15
	R_MD5(59)=21
	R_MD5(60)=6
	R_MD5(61)=10
	R_MD5(62)=15
	R_MD5(63)=21
	
	K_SHA2XX(0)=1116352408
	K_SHA2XX(1)=1899447441
	K_SHA2XX(2)=-1245643825
	K_SHA2XX(3)=-373957723
	K_SHA2XX(4)=961987163
	K_SHA2XX(5)=1508970993
	K_SHA2XX(6)=-1841331548
	K_SHA2XX(7)=-1424204075
	K_SHA2XX(8)=-670586216
	K_SHA2XX(9)=310598401
	K_SHA2XX(10)=607225278
	K_SHA2XX(11)=1426881987
	K_SHA2XX(12)=1925078388
	K_SHA2XX(13)=-2132889090
	K_SHA2XX(14)=-1680079193
	K_SHA2XX(15)=-1046744716
	K_SHA2XX(16)=-459576895
	K_SHA2XX(17)=-272742522
	K_SHA2XX(18)=264347078
	K_SHA2XX(19)=604807628
	K_SHA2XX(20)=770255983
	K_SHA2XX(21)=1249150122
	K_SHA2XX(22)=1555081692
	K_SHA2XX(23)=1996064986
	K_SHA2XX(24)=-1740746414
	K_SHA2XX(25)=-1473132947
	K_SHA2XX(26)=-1341970488
	K_SHA2XX(27)=-1084653625
	K_SHA2XX(28)=-958395405
	K_SHA2XX(29)=-710438585
	K_SHA2XX(30)=113926993
	K_SHA2XX(31)=338241895
	K_SHA2XX(32)=666307205
	K_SHA2XX(33)=773529912
	K_SHA2XX(34)=1294757372
	K_SHA2XX(35)=1396182291
	K_SHA2XX(36)=1695183700
	K_SHA2XX(37)=1986661051
	K_SHA2XX(38)=-2117940946
	K_SHA2XX(39)=-1838011259
	K_SHA2XX(40)=-1564481375
	K_SHA2XX(41)=-1474664885
	K_SHA2XX(42)=-1035236496
	K_SHA2XX(43)=-949202525
	K_SHA2XX(44)=-778901479
	K_SHA2XX(45)=-694614492
	K_SHA2XX(46)=-200395387
	K_SHA2XX(47)=275423344
	K_SHA2XX(48)=430227734
	K_SHA2XX(49)=506948616
	K_SHA2XX(50)=659060556
	K_SHA2XX(51)=883997877
	K_SHA2XX(52)=958139571
	K_SHA2XX(53)=1322822218
	K_SHA2XX(54)=1537002063
	K_SHA2XX(55)=1747873779
	K_SHA2XX(56)=1955562222
	K_SHA2XX(57)=2024104815
	K_SHA2XX(58)=-2067236844
	K_SHA2XX(59)=-1933114872
	K_SHA2XX(60)=-1866530822
	K_SHA2XX(61)=-1538233109
	K_SHA2XX(62)=-1090935817
	K_SHA2XX(63)=-965641998
	
	K_SHA5XX(0)=(i1=1116352408,i0=-685199838)
	K_SHA5XX(1)=(i1=1899447441,i0=602891725)
	K_SHA5XX(2)=(i1=-1245643825,i0=-330482897)
	K_SHA5XX(3)=(i1=-373957723,i0=-2121671748)
	K_SHA5XX(4)=(i1=961987163,i0=-213338824)
	K_SHA5XX(5)=(i1=1508970993,i0=-1241133031)
	K_SHA5XX(6)=(i1=-1841331548,i0=-1357295717)
	K_SHA5XX(7)=(i1=-1424204075,i0=-630357736)
	K_SHA5XX(8)=(i1=-670586216,i0=-1560083902)
	K_SHA5XX(9)=(i1=310598401,i0=1164996542)
	K_SHA5XX(10)=(i1=607225278,i0=1323610764)
	K_SHA5XX(11)=(i1=1426881987,i0=-704662302)
	K_SHA5XX(12)=(i1=1925078388,i0=-226784913)
	K_SHA5XX(13)=(i1=-2132889090,i0=991336113)
	K_SHA5XX(14)=(i1=-1680079193,i0=633803317)
	K_SHA5XX(15)=(i1=-1046744716,i0=-815192428)
	K_SHA5XX(16)=(i1=-459576895,i0=-1628353838)
	K_SHA5XX(17)=(i1=-272742522,i0=944711139)
	K_SHA5XX(18)=(i1=264347078,i0=-1953704523)
	K_SHA5XX(19)=(i1=604807628,i0=2007800933)
	K_SHA5XX(20)=(i1=770255983,i0=1495990901)
	K_SHA5XX(21)=(i1=1249150122,i0=1856431235)
	K_SHA5XX(22)=(i1=1555081692,i0=-1119749164)
	K_SHA5XX(23)=(i1=1996064986,i0=-2096016459)
	K_SHA5XX(24)=(i1=-1740746414,i0=-295247957)
	K_SHA5XX(25)=(i1=-1473132947,i0=766784016)
	K_SHA5XX(26)=(i1=-1341970488,i0=-1728372417)
	K_SHA5XX(27)=(i1=-1084653625,i0=-1091629340)
	K_SHA5XX(28)=(i1=-958395405,i0=1034457026)
	K_SHA5XX(29)=(i1=-710438585,i0=-1828018395)
	K_SHA5XX(30)=(i1=113926993,i0=-536640913)
	K_SHA5XX(31)=(i1=338241895,i0=168717936)
	K_SHA5XX(32)=(i1=666307205,i0=1188179964)
	K_SHA5XX(33)=(i1=773529912,i0=1546045734)
	K_SHA5XX(34)=(i1=1294757372,i0=1522805485)
	K_SHA5XX(35)=(i1=1396182291,i0=-1651133473)
	K_SHA5XX(36)=(i1=1695183700,i0=-1951439906)
	K_SHA5XX(37)=(i1=1986661051,i0=1014477480)
	K_SHA5XX(38)=(i1=-2117940946,i0=1206759142)
	K_SHA5XX(39)=(i1=-1838011259,i0=344077627)
	K_SHA5XX(40)=(i1=-1564481375,i0=1290863460)
	K_SHA5XX(41)=(i1=-1474664885,i0=-1136513023)
	K_SHA5XX(42)=(i1=-1035236496,i0=-789014639)
	K_SHA5XX(43)=(i1=-949202525,i0=106217008)
	K_SHA5XX(44)=(i1=-778901479,i0=-688958952)
	K_SHA5XX(45)=(i1=-694614492,i0=1432725776)
	K_SHA5XX(46)=(i1=-200395387,i0=1467031594)
	K_SHA5XX(47)=(i1=275423344,i0=851169720)
	K_SHA5XX(48)=(i1=430227734,i0=-1194143544)
	K_SHA5XX(49)=(i1=506948616,i0=1363258195)
	K_SHA5XX(50)=(i1=659060556,i0=-544281703)
	K_SHA5XX(51)=(i1=883997877,i0=-509917016)
	K_SHA5XX(52)=(i1=958139571,i0=-976659869)
	K_SHA5XX(53)=(i1=1322822218,i0=-482243893)
	K_SHA5XX(54)=(i1=1537002063,i0=2003034995)
	K_SHA5XX(55)=(i1=1747873779,i0=-692930397)
	K_SHA5XX(56)=(i1=1955562222,i0=1575990012)
	K_SHA5XX(57)=(i1=2024104815,i0=1125592928)
	K_SHA5XX(58)=(i1=-2067236844,i0=-1578062990)
	K_SHA5XX(59)=(i1=-1933114872,i0=442776044)
	K_SHA5XX(60)=(i1=-1866530822,i0=593698344)
	K_SHA5XX(61)=(i1=-1538233109,i0=-561857047)
	K_SHA5XX(62)=(i1=-1090935817,i0=-1295615723)
	K_SHA5XX(63)=(i1=-965641998,i0=-479046869)
	K_SHA5XX(64)=(i1=-903397682,i0=-366583396)
	K_SHA5XX(65)=(i1=-779700025,i0=566280711)
	K_SHA5XX(66)=(i1=-354779690,i0=-840897762)
	K_SHA5XX(67)=(i1=-176337025,i0=-294727304)
	K_SHA5XX(68)=(i1=116418474,i0=1914138554)
	K_SHA5XX(69)=(i1=174292421,i0=-1563912026)
	K_SHA5XX(70)=(i1=289380356,i0=-1090974290)
	K_SHA5XX(71)=(i1=460393269,i0=320620315)
	K_SHA5XX(72)=(i1=685471733,i0=587496836)
	K_SHA5XX(73)=(i1=852142971,i0=1086792851)
	K_SHA5XX(74)=(i1=1017036298,i0=365543100)
	K_SHA5XX(75)=(i1=1126000580,i0=-1676669620)
	K_SHA5XX(76)=(i1=1288033470,i0=-885112138)
	K_SHA5XX(77)=(i1=1501505948,i0=-60457430)
	K_SHA5XX(78)=(i1=1607167915,i0=987167468)
	K_SHA5XX(79)=(i1=1816402316,i0=1246189591)
}


