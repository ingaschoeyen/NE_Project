import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

file_path = ''

dataset  pd.read_csv(file_path, header=None)

data_frame = pd.DataFrame(dataset)

data_array = np.array(data_frame.values)

print(data_array.shape)