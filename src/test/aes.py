from Crypto.Cipher import AES
from Crypto import Random
import struct
import binascii

key = (0xfefd00d583ef87e9b7e6ab3a655f68db).to_bytes(16, 'big')
chipher = AES.new(key, AES.MODE_CBC, IV = (0x0).to_bytes(16, 'big'))
print(binascii.hexlify(key))
print(binascii.hexlify(b'\x00\x00\x00\x08\x00\x00\x00\x07\x00\x00\x00\x06\x00\x00\x00\x05'))
print(binascii.hexlify(chipher.encrypt(b'\x00\x00\x00\x08\x00\x00\x00\x07\x00\x00\x00\x06\x00\x00\x00\x05')))
