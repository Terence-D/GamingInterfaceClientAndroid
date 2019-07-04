package ca.coffeeshopstudio.gaminginterfaceclient.network;

import java.util.List;

import ca.coffeeshopstudio.gaminginterfaceclient.models.Command;
import ca.coffeeshopstudio.gaminginterfaceclient.models.Result;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.Header;
import retrofit2.http.POST;

/**
 Copyright [2019] [Terence Doerksen]

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
public interface CommandService {
    @GET("/api/Version")
    Call<String> getVersion();

    @POST("/api/toggle")
    Call<List<Result>> postToggleCommand(@Header("Authorization") String auth, @Body Command command);

    @POST("/api/key")
    Call<List<Result>> postComplexCommand(@Header("Authorization") String auth, @Body Command command);
}
