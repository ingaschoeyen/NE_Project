import spike_data
import numpy as np
import matplotlib.pyplot as plt


# class of readout network, including initialisation, training and testing
class readoutNet():
    def __init__(self, data, output_size=32, lr=0.01, train_size=0.8):
        self.train_data = data.spike_times[:int(train_size*data.spike_times.shape[0])]
        self.test_data = data.spike_times[int(train_size*data.spike_times.shape[0]):]
        self.input_size = data.spike_times.shape[1]
        self.output_size = output_size
        # scale the input signal to the range of the output
        self.target_train = self.generate_target(data.input_signal[:int(train_size*data.spike_times.shape[0])])
        self.target_test = self.generate_target(data.input_signal[int(train_size*data.spike_times.shape[0]):])
        self.W_init = np.random.randn(self.input_size, self.output_size)
        self.W = self.W_init
        self.b_init = np.random.randn(self.output_size)
        self.b = self.b_init
        self.lr = lr

    def generate_target(self, signal):
        target = np.zeros((signal.shape[0], self.output_size))
        # get target min and max, round to lower and higher integer
        target_min = np.floor(np.min(signal))
        target_max = np.ceil(np.max(signal))
        # scale the signal to the range of the output
        if self.output_size == 1:
            target = (signal - target_min) / (target_max - target_min)
        else:
            scaled_signal = (signal - target_min) / (target_max - target_min) * (self.output_size - 1)
            for i in range(signal.shape[0]):
                target[i, int(scaled_signal[i])] = 1
        return target

    def train(self, epochs=1000, batch_size=100):
        self.error = np.zeros(epochs)
        lr = self.lr
        W_train = self.W
        b_train = self.b
        for epoch in range(epochs):
            epoch_error = 0
            for i in range(0, self.train_data.shape[0], batch_size):
                # Get batch data
                batch_data = self.train_data[i:i+batch_size]
                batch_target = self.target_train[i:i+batch_size]

                # Forward pass
                z = np.dot(batch_data, W_train) + b_train
                y = 1 / (1 + np.exp(-z))  # Sigmoid activation
                y = np.max(y)
                # Compute error
                batch_error = batch_target - y  # Shape: (batch_size, output_size)

                # Backpropagation
                dW = np.dot(batch_data.T, batch_error * y * (1 - y)) / batch_size  # Derivative of sigmoid
                db = np.mean(batch_error * y * (1 - y), axis=0)

                # Update weights and biases
                W_train += lr * dW
                b_train += lr * db

                # Accumulate error for this epoch
                epoch_error += np.mean((batch_target - y) ** 2)

            # Store epoch error (RMSE)
            self.error[epoch] = np.sqrt(epoch_error / (self.train_data.shape[0] / batch_size))

            if epoch % 100 == 0:
                print(f'Epoch {epoch}: RMSE = {self.error[epoch]}')

        # Update model parameters
        self.W = W_train
        self.b = b_train
        return self.W, self.b

    
    def test(self):
        z = np.dot(self.test_data, self.W) + self.b
        y = 1 / (1 + np.exp(-z))
        error = np.mean((self.target_test - y) ** 2)
        return error

    def predict(self):
        # forward pass with test data
        net_out = np.dot(self.test_data, self.W) + self.b
        target_range = np.max(self.target_test)-np.max(self.target_test)
        if self.output_size == 1:
            prediction = target_range*net_out
        else:
            max_index = np.argmax(net_out, axis=1)
            # make prediction based on index with max value
            prediction = target_range*max_index/(self.output_size-1)
        return prediction

    def plot_error(self):
        plt.plot(self.error, label='Train Error')
        plt.axhline(self.test(), label='Test Error', '--', color='red')
        plt.title('Train Outcome')
        plt.xlabel('Time')
        plt.ylabel('Signal')
        plt.legend()
        plt.show() 

    def plot_prediction(self):
        plt.plot(self.target_test, label='Target')
        plt.plot(self.predict(), label='Prediction')
        plt.title('Prediction')
        plt.xlabel('Time')
        plt.ylabel('Signal')
        plt.legend()
        plt.show()


if __name__ == "__main__":
    file_path = 'sim_res/output_waveforms_sine.csv'
    data = spike_data.spikeData(file_path)
    readout = readoutNet(data)
    W, b = readout.train()
    y = readout.test()
    readout.plot_error()
    readout.plot_prediction()