import zipfile
import glob
import os
import os.path as osp

def main():
    with zipfile.ZipFile('ATOInformer.zip', 'w', compression=zipfile.ZIP_DEFLATED) as myzip:
        for file in glob.glob('./**', recursive=True):
            if '.zip' in file:
                continue

            print(file)
            myzip.write(file, osp.join('ATOInformer', file))

if __name__ == "__main__":
    main()